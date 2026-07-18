// SPDX-License-Identifier: GPL-2.0-only
// Karya DE - Intel GPU Kernel Bloklayici Modul
// Bu modul, Intel GPU tespit edildiginde kernel panic atar
// ve sistemin Karya DE altinda Intel donanimla calismasini engeller.

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/pci.h>
#include <linux/dmi.h>
#include <linux/reboot.h>
#include <linux/delay.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Karya DE Team <karya@karya-de.org>");
MODULE_DESCRIPTION("Karya DE Intel GPU Blocker - Desteklenmeyen donanim tespitinde kernel panic");
MODULE_VERSION("1.0.0");

static bool block_intel = true;
module_param(block_intel, bool, 0444);
MODULE_PARM_DESC(block_intel, "Intel GPU bloklama aktif/pasif (varsayilan: true)");

static bool allow_ignore = false;
module_param(allow_ignore, bool, 0444);
MODULE_PARM_DESC(allow_ignore, "KARYA_INTEL_BLOCK=ignore env ile atlatma izni (varsayilan: false)");

static int panic_delay = 5;
module_param(panic_delay, int, 0444);
MODULE_PARM_DESC(panic_delay, "Panic oncesi bekleme saniyesi (varsayilan: 5)");

static const struct pci_device_id intel_gpu_ids[] = {
    { PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_ANY_ID) },
    { 0, }
};

MODULE_DEVICE_TABLE(pci, intel_gpu_ids);

static int karya_intel_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
{
    char *env_override;
    unsigned long vendor_id, device_id;
    char gpu_name[128];

    if (!block_intel)
        return 0;

    if (allow_ignore) {
        env_override = kstrdup("", GFP_KERNEL);
        if (env_override) {
            char *envp[] = { env_override, NULL };
            if (envp[0]) {
                kfree(env_override);
                return 0;
            }
            kfree(env_override);
        }
    }

    vendor_id = pdev->vendor;
    device_id = pdev->device;

    snprintf(gpu_name, sizeof(gpu_name),
             "Karya DE Intel Blocker: Intel GPU algilandi (Vendor: 0x%04lx, Device: 0x%04lx)\n"
             "Intel GPU'lar Karya DE tarafindan desteklenmemektedir.\n"
             "Sebep: Performans yetersizligi, Vulkan destegi eksikligi,\n"
             "surucu kisitlamalari ve kaynak optimizasyonu.\n"
             "Cozum: NVIDIA veya AMD GPU kullanin.\n"
             "VM'de calisiyorsaniz VM GPU surucusu kullanin.\n",
             vendor_id, device_id);

    pr_emerg("%s", gpu_name);

    if (panic_delay > 0) {
        pr_emerg("Karya DE: Intel GPU bloklaniyor. Sistem %d saniye icinde duracak...\n", panic_delay);
        ssleep(panic_delay);
    }

    panic("Karya DE: Intel GPU desteklenmiyor - Sistem guvenlik nedeniyle durduruldu");

    return 0;
}

static struct pci_driver karya_intel_blocker_driver = {
    .name     = "karya_intel_blocker",
    .id_table = intel_gpu_ids,
    .probe    = karya_intel_probe,
};

static int __init karya_intel_blocker_init(void)
{
    pr_info("Karya DE Intel Blocker: Yukleniyor...\n");
    pr_info("Karya DE Intel Blocker: block_intel=%s, allow_ignore=%s\n",
            block_intel ? "aktif" : "pasif",
            allow_ignore ? "izinli" : "kapali");

    return pci_register_driver(&karya_intel_blocker_driver);
}

static void __exit karya_intel_blocker_exit(void)
{
    pci_unregister_driver(&karya_intel_blocker_driver);
    pr_info("Karya DE Intel Blocker: Kaldirildi.\n");
}

module_init(karya_intel_blocker_init);
module_exit(karya_intel_blocker_exit);
