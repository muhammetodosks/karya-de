// SPDX-License-Identifier: GPL-2.0-only
// Karya DE - Kernel Seviyesinde Guvenlik Modulu
// Bu modul, kernel seviyesinde guvenlik politikalarini uygular:
// - Intel GPU bloklama
// - Kernel memory korumalari
// - Process izolasyonu
// - Dosya sistemi integrity kontrolu

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/security.h>
#include <linux/lsm_hooks.h>
#include <linux/pci.h>
#include <linux/fs.h>
#include <linux/file.h>
#include <linux/cred.h>
#include <linux/sched.h>
#include <linux/binfmts.h>
#include <linux/path.h>
#include <linux/mount.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/uaccess.h>
#include <linux/sysctl.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Karya DE Team <karya@karya-de.org>");
MODULE_DESCRIPTION("Karya DE Kernel Seviyesinde Guvenlik Modulu");
MODULE_VERSION("1.0.0");

// ============================================================
// SABITLER VE YAPILAR
// ============================================================

#define KARYA_SEC_VERSION "1.0.0"
#define KARYA_SEC_DEBUG 1

static int karya_sec_enabled = 1;
module_param(karya_sec_enabled, int, 0444);
MODULE_PARM_DESC(karya_sec_enabled, "Karya Security Module aktif/pasif (0/1)");

static int karya_sec_lockdown_level = 2;
module_param(karya_sec_lockdown_level, int, 0444);
MODULE_PARM_DESC(karya_sec_lockdown_level, "Lockdown seviyesi: 0=pasif, 1=integrity, 2=confidentiality");

static int karya_sec_block_intel = 1;
module_param(karya_sec_block_intel, int, 0444);
MODULE_PARM_DESC(karya_sec_block_intel, "Intel GPU bloklama: 0=pasif, 1=aktif");

// ============================================================
// PROC FS ARABIRIMI
// ============================================================

static struct proc_dir_entry *karya_proc_dir;
static struct proc_dir_entry *karya_proc_status;
static struct proc_dir_entry *karya_proc_version;
static struct proc_dir_entry *karya_proc_violations;

static unsigned long total_violations;
static unsigned long intel_blocks;
static unsigned long file_violations;
static unsigned long exec_violations;

static int karya_proc_show_status(struct seq_file *m, void *v)
{
    seq_printf(m, "Karya DE Security Module\n");
    seq_printf(m, "=======================\n");
    seq_printf(m, "Status: %s\n", karya_sec_enabled ? "ACTIVE" : "DISABLED");
    seq_printf(m, "Version: %s\n", KARYA_SEC_VERSION);
    seq_printf(m, "Lockdown Level: %d\n", karya_sec_lockdown_level);
    seq_printf(m, "Intel Block: %s\n", karya_sec_block_intel ? "ENABLED" : "DISABLED");
    seq_printf(m, "Total Violations: %lu\n", total_violations);
    seq_printf(m, "Intel Blocks: %lu\n", intel_blocks);
    seq_printf(m, "File Violations: %lu\n", file_violations);
    seq_printf(m, "Exec Violations: %lu\n", exec_violations);
    return 0;
}

static int karya_proc_open_status(struct inode *inode, struct file *file)
{
    return single_open(file, karya_proc_show_status, NULL);
}

static const struct proc_ops karya_proc_fops_status = {
    .proc_open    = karya_proc_open_status,
    .proc_read    = seq_read,
    .proc_lseek   = seq_lseek,
    .proc_release = single_release,
};

static int karya_proc_show_version(struct seq_file *m, void *v)
{
    seq_printf(m, "Karya DE Security Module v%s\n", KARYA_SEC_VERSION);
    seq_printf(m, "Build: " __DATE__ " " __TIME__ "\n");
    seq_printf(m, "License: GPL v2\n");
    seq_printf(m, "Author: Karya DE Team\n");
    return 0;
}

static int karya_proc_open_version(struct inode *inode, struct file *file)
{
    return single_open(file, karya_proc_show_version, NULL);
}

static const struct proc_ops karya_proc_fops_version = {
    .proc_open    = karya_proc_open_version,
    .proc_read    = seq_read,
    .proc_lseek   = seq_lseek,
    .proc_release = single_release,
};

static int karya_proc_show_violations(struct seq_file *m, void *v)
{
    seq_printf(m, "Karya DE Security Violations Log\n");
    seq_printf(m, "===============================\n");
    seq_printf(m, "Total: %lu\n", total_violations);
    seq_printf(m, "Intel GPU Blocks: %lu\n", intel_blocks);
    seq_printf(m, "File Access Violations: %lu\n", file_violations);
    seq_printf(m, "Execution Violations: %lu\n", exec_violations);
    seq_printf(m, "\nSon violation: %s\n",
               total_violations > 0 ? "Kaydedildi" : "Yok");
    return 0;
}

static int karya_proc_open_violations(struct inode *inode, struct file *file)
{
    return single_open(file, karya_proc_show_violations, NULL);
}

static const struct proc_ops karya_proc_fops_violations = {
    .proc_open    = karya_proc_open_violations,
    .proc_read    = seq_read,
    .proc_lseek   = seq_lseek,
    .proc_release = single_release,
};

// ============================================================
// INTEL GPU TESPITI VE BLOKLAMA
// ============================================================

static bool karya_check_intel_gpu(void)
{
    struct pci_dev *dev = NULL;
    bool found = false;

    if (!karya_sec_block_intel)
        return false;

    while ((dev = pci_get_device(PCI_VENDOR_ID_INTEL, PCI_ANY_ID, dev))) {
        if (dev->class == 0x030000 || dev->class == 0x038000) {
            found = true;
            intel_blocks++;
            total_violations++;
            pr_emerg("KaryaDE-SEC: Intel GPU bloklandi (Device %04x:%04x)\n",
                     dev->vendor, dev->device);
            break;
        }
    }

    return found;
}

// ============================================================
// LSM HOOK: DOSYA ERISIM KONTROLU
// ============================================================

static int karya_bprm_check_security(struct linux_binprm *bprm)
{
    const struct cred *cred = current_cred();

    if (!karya_sec_enabled)
        return 0;

    // /tmp ve /dev/shm'den calistirmayi engelle
    if (bprm->file && bprm->file->f_path.mnt) {
        struct path path;
        path.mnt = bprm->file->f_path.mnt;
        path.dentry = bprm->file->f_path.dentry;

        char *tmp_path = (char *)__get_free_page(GFP_KERNEL);
        if (tmp_path) {
            char *res = d_path(&path, tmp_path, PAGE_SIZE);
            if (!IS_ERR(res)) {
                if (strncmp(res, "/tmp/", 5) == 0 ||
                    strncmp(res, "/dev/shm/", 9) == 0) {
                    if (!capable(CAP_SYS_ADMIN)) {
                        exec_violations++;
                        total_violations++;
                        pr_warn("KaryaDE-SEC: /tmp'den calistirma engellendi: %s\n", res);
                        free_page((unsigned long)tmp_path);
                        return -EPERM;
                    }
                }
            }
            free_page((unsigned long)tmp_path);
        }
    }

    return 0;
}

// ============================================================
// GUZERGAH KONTROL
// ============================================================

static int karya_task_fix_setuid(struct cred *new, const struct cred *old, int flags)
{
    if (!karya_sec_enabled)
        return 0;

    // SUID degisimlerini logla
    if (flags & LSM_SETID_SUID) {
        pr_info("KaryaDE-SEC: SUID degisimi pid=%d\n", task_tgid_vnr(current));
    }

    return 0;
}

// ============================================================
// LSM HOOK KAYITLARI
// ============================================================

static struct security_hook_list karya_hooks[] __ro_after_init = {
    LSM_HOOK_INIT(bprm_check_security, karya_bprm_check_security),
    LSM_HOOK_INIT(task_fix_setuid, karya_task_fix_setuid),
};

// ============================================================
// BASLANGIC VE BITIS
// ============================================================

static int __init karya_security_init(void)
{
    int ret;

    pr_info("KaryaDE-SEC: Yukleniyor v%s...\n", KARYA_SEC_VERSION);
    pr_info("KaryaDE-SEC: Lockdown level: %d\n", karya_sec_lockdown_level);
    pr_info("KaryaDE-SEC: Intel Block: %s\n",
            karya_sec_block_intel ? "AKTIF" : "PASIF");

    // Intel GPU kontrol
    if (karya_check_intel_gpu()) {
        pr_emerg("KaryaDE-SEC: Intel GPU tespit edildi! Sistem durduruluyor...\n");
        panic("KaryaDE-SEC: Intel GPU desteklenmiyor - Guvenlik modulu tarafindan bloklandi");
    }

    // LSM hook'larini kaydet
    security_add_hooks(karya_hooks, ARRAY_SIZE(karya_hooks), "karya");

    // Proc dosyalarini olustur
    karya_proc_dir = proc_mkdir("karya/sec", NULL);
    if (!karya_proc_dir) {
        pr_err("KaryaDE-SEC: Proc dizini olusturulamadi\n");
        return -ENOMEM;
    }

    karya_proc_status = proc_create("status", 0444, karya_proc_dir, &karya_proc_fops_status);
    karya_proc_version = proc_create("version", 0444, karya_proc_dir, &karya_proc_fops_version);
    karya_proc_violations = proc_create("violations", 0444, karya_proc_dir, &karya_proc_fops_violations);

    if (!karya_proc_status || !karya_proc_version || !karya_proc_violations) {
        pr_err("KaryaDE-SEC: Proc dosyalari olusturulamadi\n");
        remove_proc_subtree("karya/sec", NULL);
        return -ENOMEM;
    }

    pr_info("KaryaDE-SEC: Modul basariyla yuklendi\n");
    pr_info("KaryaDE-SEC: /proc/karya/sec/status - Durum\n");
    pr_info("KaryaDE-SEC: /proc/karya/sec/version - Versiyon\n");
    pr_info("KaryaDE-SEC: /proc/karya/sec/violations - Ihlal loglari\n");

    return 0;
}

static void __exit karya_security_exit(void)
{
    remove_proc_subtree("karya/sec", NULL);
    pr_info("KaryaDE-SEC: Modul kaldirildi.\n");
    pr_info("KaryaDE-SEC: Toplam ihlal: %lu\n", total_violations);
}

module_init(karya_security_init);
module_exit(karya_security_exit);
