{
  fetchpatch,
  lib,
  linuxKernel,
  zfs,
}:

let
  inherit (zfs) kernelModuleAttribute;

  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    let
      zfsPackage = kernelPackages.${kernelModuleAttribute} or null;
      zfsPackageEval = builtins.tryEval zfsPackage;
    in
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (kernelPackages.kernel.isLTS or false)
    && zfsPackageEval.success
    && zfsPackage != null
    && (!(zfsPackage.meta.broken or false))
  ) linuxKernel.packages;

  baseLinuxPackages = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );

  neulandKernelPatches = [
    {
      name = "ptrace-slightly-saner-get_dumpable-logic.patch";
      patch = fetchpatch {
        name = "ptrace-slightly-saner-get_dumpable-logic.patch";
        url = "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/patch/?id=01363cb3fbd0238ffdeb09f53e9039c9edf8a730";
        hash = "sha256-eg0T5t94z3Nta98O+8bxwgCYDr6T4szZ9IOp/f4TXMs=";
      };
    }
    {
      name = "disable unused kernel features";
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        AF_RXRPC = lib.mkForce no;
        AFS_FS = lib.mkForce no;
        INET_ESP = lib.mkForce no;
        INET6_ESP = lib.mkForce no;
        INET_ESP_OFFLOAD = unset;
        INET6_ESP_OFFLOAD = unset;
        INET_ESPINTCP = lib.mkForce unset;
        INET6_ESPINTCP = lib.mkForce unset;
        RDS = lib.mkForce no;
        RDS_TCP = lib.mkForce unset;
        RDS_RDMA = lib.mkForce unset;
        RDS_DEBUG = lib.mkForce unset;
        TIPC = lib.mkForce no;
        TIPC_MEDIA_IB = lib.mkForce unset;
        TIPC_MEDIA_UDP = lib.mkForce unset;
        TIPC_CRYPTO = lib.mkForce unset;
        TIPC_DIAG = lib.mkForce unset;
        ATM = lib.mkForce no;
        ATM_LANE = lib.mkForce unset;
        ATM_BR2684 = lib.mkForce unset;
        L2TP = lib.mkForce no;
        L2TP_V3 = lib.mkForce unset;
        L2TP_IP = lib.mkForce unset;
        L2TP_ETH = lib.mkForce unset;
        L2TP_DEBUGFS = lib.mkForce unset;
        HDLC = lib.mkForce no;
        HDLC_RAW = lib.mkForce unset;
        HDLC_RAW_ETH = lib.mkForce unset;
        HDLC_CISCO = lib.mkForce unset;
        HDLC_FR = lib.mkForce unset;
        HDLC_PPP = lib.mkForce unset;
        HDLC_X25 = lib.mkForce unset;
        X25 = lib.mkForce no;
        LAPB = lib.mkForce no;
        CAN = lib.mkForce no;
        CAN_RAW = lib.mkForce unset;
        CAN_BCM = lib.mkForce unset;
        CAN_GW = lib.mkForce unset;
        CAN_J1939 = lib.mkForce unset;
        CAN_ISOTP = lib.mkForce unset;
        CAN_DEV = lib.mkForce unset;
        NFC = lib.mkForce no;
        NFC_DIGITAL = lib.mkForce unset;
        NFC_NCI = lib.mkForce unset;
        NFC_HCI = lib.mkForce unset;
        NFC_SHDLC = lib.mkForce unset;
        "6LOWPAN" = lib.mkForce no;
        "6LOWPAN_DEBUGFS" = lib.mkForce unset;
        IEEE802154 = lib.mkForce no;
        IEEE802154_NL802154_EXPERIMENTAL = lib.mkForce unset;
        MAC802154 = lib.mkForce unset;
        IEEE802154_6LOWPAN = lib.mkForce unset;
        BT = lib.mkForce no;
        BT_BREDR = lib.mkForce unset;
        BT_RFCOMM = lib.mkForce unset;
        BT_BNEP = lib.mkForce unset;
        BT_HIDP = lib.mkForce unset;
        BT_LE = lib.mkForce unset;
        BT_HCIBTUSB_AUTOSUSPEND = lib.mkForce unset;
        BT_HCIBTUSB_MTK = lib.mkForce unset;
        BT_HCIUART = lib.mkForce unset;
        BT_HCIUART_QCA = lib.mkForce unset;
        BT_HCIUART_SERDEV = lib.mkForce unset;
        BT_QCA = lib.mkForce unset;
        HAMRADIO = lib.mkForce no;
        AX25 = lib.mkForce unset;
        BATMAN_ADV = lib.mkForce no;
        OPENVSWITCH = lib.mkForce no;
        GENEVE = lib.mkForce no;
        NET_9P = lib.mkForce no;
        NET_9P_VIRTIO = lib.mkForce unset;
        NET_9P_XEN = lib.mkForce unset;

        SOUND = no;
        SND_HDA_PATCH_LOADER = lib.mkForce unset;
        SND_HDA_POWER_SAVE_DEFAULT = lib.mkForce unset;
        SND_HDA_RECONFIG = lib.mkForce unset;
        SND_OSSEMUL = lib.mkForce unset;
        SND_SOC_INTEL_SOUNDWIRE_SOF_MACH = lib.mkForce unset;
        SND_SOC_INTEL_USER_FRIENDLY_LONG_NAMES = lib.mkForce unset;
        SND_SOC_SOF_ACPI = lib.mkForce unset;
        SND_SOC_SOF_APOLLOLAKE = lib.mkForce unset;
        SND_SOC_SOF_CANNONLAKE = lib.mkForce unset;
        SND_SOC_SOF_COFFEELAKE = lib.mkForce unset;
        SND_SOC_SOF_COMETLAKE = lib.mkForce unset;
        SND_SOC_SOF_ELKHARTLAKE = lib.mkForce unset;
        SND_SOC_SOF_GEMINILAKE = lib.mkForce unset;
        SND_SOC_SOF_HDA_AUDIO_CODEC = lib.mkForce unset;
        SND_SOC_SOF_HDA_LINK = lib.mkForce unset;
        SND_SOC_SOF_ICELAKE = lib.mkForce unset;
        SND_SOC_SOF_INTEL_TOPLEVEL = lib.mkForce unset;
        SND_SOC_SOF_JASPERLAKE = lib.mkForce unset;
        SND_SOC_SOF_MERRIFIELD = lib.mkForce unset;
        SND_SOC_SOF_PCI = lib.mkForce unset;
        SND_SOC_SOF_TIGERLAKE = lib.mkForce unset;
        SND_SOC_SOF_TOPLEVEL = lib.mkForce unset;
        SND_USB_AUDIO_MIDI_V2 = lib.mkForce unset;
        SND_USB_CAIAQ_INPUT = lib.mkForce unset;
        SND_AC97_POWER_SAVE = lib.mkForce unset;
        SND_AC97_POWER_SAVE_DEFAULT = lib.mkForce unset;
        SND_DYNAMIC_MINORS = lib.mkForce unset;
        SND_HDA_CODEC_CS8409 = lib.mkForce unset;
        SND_HDA_INPUT_BEEP = lib.mkForce unset;

        XEN = lib.mkForce no;
        XEN_SAVE_RESTORE = lib.mkForce unset;
        SWIOTLB_XEN = lib.mkForce unset;
        XEN_BACKEND = lib.mkForce unset;
        XEN_BALLOON = lib.mkForce unset;
        XEN_BALLOON_MEMORY_HOTPLUG = lib.mkForce unset;
        XEN_DOM0 = lib.mkForce unset;
        XEN_EFI = lib.mkForce unset;
        XEN_HAVE_PVMMU = lib.mkForce unset;
        XEN_MCE_LOG = lib.mkForce unset;
        XEN_PVH = lib.mkForce unset;
        XEN_PVHVM = lib.mkForce unset;
        XEN_SYS_HYPERVISOR = lib.mkForce unset;
        HVC_XEN = lib.mkForce unset;
        HVC_XEN_FRONTEND = lib.mkForce unset;
        PCI_XEN = lib.mkForce unset;

        WLAN = no;
        IPW2100_MONITOR = lib.mkForce unset;
        IPW2200_MONITOR = lib.mkForce unset;
        RT2800USB_RT53XX = lib.mkForce unset;
        RT2800USB_RT55XX = lib.mkForce unset;
        RTW88 = lib.mkForce unset;
        RTW88_8822BE = lib.mkForce unset;
        RTW88_8822CE = lib.mkForce unset;

        INPUT_JOYSTICK = lib.mkForce no;
        JOYSTICK_PSXPAD_SPI_FF = lib.mkForce unset;
        NVIDIA_SHIELD_FF = lib.mkForce unset;

        INFINIBAND = lib.mkForce no;
        INFINIBAND_IPOIB = lib.mkForce unset;
        INFINIBAND_IPOIB_CM = lib.mkForce unset;
      };
    }
  ];

  neulandKernel = baseLinuxPackages.kernel.override {
    kernelPatches = (baseLinuxPackages.kernel.kernelPatches or [ ]) ++ neulandKernelPatches;
  };
in
linuxKernel.packagesFor neulandKernel
