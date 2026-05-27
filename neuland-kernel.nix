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
      name = "disable unused kernel features";
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        # IPsec ESP is not used on these hosts.
        INET_ESP = lib.mkForce no;
        INET6_ESP = lib.mkForce no;
        INET_ESP_OFFLOAD = unset;
        INET6_ESP_OFFLOAD = unset;
        INET_ESPINTCP = lib.mkForce unset;
        INET6_ESPINTCP = lib.mkForce unset;

        # Unused network protocols and encapsulations. VXLAN is intentionally
        # left enabled because the infrastructure uses it.
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

        # Network transports for disabled filesystems.
        AF_RXRPC = lib.mkForce no; # AFS transport.

        # Unused network/distributed filesystems. NFS client/server and FUSE
        # are intentionally left enabled.
        AFS_FS = lib.mkForce no;
        CEPH_FS = lib.mkForce no;
        CEPH_FSCACHE = lib.mkForce unset;
        CEPH_FS_POSIX_ACL = lib.mkForce unset;
        CEPH_FS_SECURITY_LABEL = lib.mkForce unset;
        CIFS = lib.mkForce no;
        CIFS_STATS2 = lib.mkForce unset;
        CIFS_ALLOW_INSECURE_LEGACY = lib.mkForce unset;
        CIFS_UPCALL = lib.mkForce unset;
        CIFS_XATTR = lib.mkForce unset;
        CIFS_POSIX = lib.mkForce unset;
        CIFS_DEBUG = lib.mkForce unset;
        CIFS_DEBUG2 = lib.mkForce unset;
        CIFS_DEBUG_DUMP_KEYS = lib.mkForce unset;
        CIFS_DFS_UPCALL = lib.mkForce unset;
        CIFS_SWN_UPCALL = lib.mkForce unset;
        CIFS_NFSD_EXPORT = lib.mkForce unset;
        CIFS_SMB_DIRECT = lib.mkForce unset;
        CIFS_FSCACHE = lib.mkForce unset;
        CIFS_ROOT = lib.mkForce unset;
        CIFS_COMPRESSION = lib.mkForce unset;
        CODA_FS = lib.mkForce no;
        ORANGEFS_FS = lib.mkForce no;
        SMB_SERVER = lib.mkForce no;
        SMB_SERVER_SMBDIRECT = lib.mkForce unset;
        SMB_SERVER_CHECK_CAP_NET_ADMIN = lib.mkForce unset;
        SMB_SERVER_KERBEROS5 = lib.mkForce unset;

        # Unused local disk and media filesystems. Required filesystems are
        # left to the nixpkgs/NixOS defaults.
        ADFS_FS = lib.mkForce no;
        ADFS_FS_RW = lib.mkForce unset;
        AFFS_FS = lib.mkForce no;
        BEFS_FS = lib.mkForce no;
        BFS_FS = lib.mkForce no;
        CRAMFS = lib.mkForce no;
        CRAMFS_BLOCKDEV = lib.mkForce unset;
        CRAMFS_MTD = lib.mkForce unset;
        ECRYPT_FS = lib.mkForce no;
        ECRYPT_FS_MESSAGING = lib.mkForce unset;
        EFS_FS = lib.mkForce no;
        EROFS_FS = lib.mkForce no;
        EROFS_FS_DEBUG = lib.mkForce unset;
        EROFS_FS_XATTR = lib.mkForce unset;
        EROFS_FS_POSIX_ACL = lib.mkForce unset;
        EROFS_FS_SECURITY = lib.mkForce unset;
        EROFS_FS_BACKED_BY_FILE = lib.mkForce unset;
        EROFS_FS_ZIP = lib.mkForce unset;
        EROFS_FS_ZIP_LZMA = lib.mkForce unset;
        EROFS_FS_ZIP_DEFLATE = lib.mkForce unset;
        EROFS_FS_ZIP_ZSTD = lib.mkForce unset;
        EROFS_FS_ZIP_ACCEL = lib.mkForce unset;
        EROFS_FS_ONDEMAND = lib.mkForce unset;
        EROFS_FS_PCPU_KTHREAD = lib.mkForce unset;
        EROFS_FS_PCPU_KTHREAD_HIPRI = lib.mkForce unset;
        EXFAT_FS = lib.mkForce no;
        EXT2_FS = lib.mkForce no;
        EXT2_FS_XATTR = lib.mkForce unset;
        EXT2_FS_POSIX_ACL = lib.mkForce unset;
        EXT2_FS_SECURITY = lib.mkForce unset;
        F2FS_FS = lib.mkForce no;
        F2FS_FS_XATTR = lib.mkForce unset;
        F2FS_FS_POSIX_ACL = lib.mkForce unset;
        F2FS_FS_SECURITY = lib.mkForce unset;
        F2FS_FS_COMPRESSION = lib.mkForce unset;
        F2FS_FS_LZO = lib.mkForce unset;
        F2FS_FS_LZORLE = lib.mkForce unset;
        F2FS_FS_LZ4 = lib.mkForce unset;
        F2FS_FS_LZ4HC = lib.mkForce unset;
        F2FS_FS_ZSTD = lib.mkForce unset;
        GFS2_FS = lib.mkForce no;
        GFS2_FS_LOCKING_DLM = lib.mkForce unset;
        HFS_FS = lib.mkForce no;
        HFSPLUS_FS = lib.mkForce no;
        HPFS_FS = lib.mkForce no;
        JFFS2_FS = lib.mkForce no;
        JFFS2_FS_DEBUG = lib.mkForce unset;
        JFFS2_FS_WRITEBUFFER = lib.mkForce unset;
        JFFS2_FS_WBUF_VERIFY = lib.mkForce unset;
        JFFS2_FS_XATTR = lib.mkForce unset;
        JFFS2_FS_POSIX_ACL = lib.mkForce unset;
        JFFS2_FS_SECURITY = lib.mkForce unset;
        JFS_FS = lib.mkForce no;
        MINIX_FS = lib.mkForce no;
        MINIX_FS_NATIVE_ENDIAN = lib.mkForce unset;
        MINIX_FS_BIG_ENDIAN_16BIT_INDEXED = lib.mkForce unset;
        NILFS2_FS = lib.mkForce no;
        NTFS_FS = lib.mkForce no;
        NTFS3_FS = lib.mkForce no;
        NTFS3_64BIT_CLUSTER = lib.mkForce unset;
        NTFS3_LZX_XPRESS = lib.mkForce unset;
        NTFS3_FS_POSIX_ACL = lib.mkForce unset;
        OCFS2_FS = lib.mkForce no;
        OCFS2_FS_O2CB = lib.mkForce unset;
        OCFS2_FS_USERSPACE_CLUSTER = lib.mkForce unset;
        OCFS2_FS_STATS = lib.mkForce unset;
        OMFS_FS = lib.mkForce no;
        QNX4FS_FS = lib.mkForce no;
        QNX6FS_FS = lib.mkForce no;
        ROMFS_FS = lib.mkForce no;
        UBIFS_FS = lib.mkForce no;
        UBIFS_FS_ADVANCED_COMPR = lib.mkForce unset;
        UBIFS_FS_LZO = lib.mkForce unset;
        UBIFS_FS_ZLIB = lib.mkForce unset;
        UBIFS_FS_ZSTD = lib.mkForce unset;
        UBIFS_FS_XATTR = lib.mkForce unset;
        UBIFS_FS_SECURITY = lib.mkForce unset;
        UBIFS_FS_AUTHENTICATION = lib.mkForce unset;
        UDF_FS = lib.mkForce no;
        UFS_FS = lib.mkForce no;
        UFS_FS_WRITE = lib.mkForce unset;
        XFS_FS = lib.mkForce no;
        ZONEFS_FS = lib.mkForce no;

        # Server kernels do not need local audio stacks.
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

        # Xen support is not needed for the target platforms.
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

        PVH = yes;

        # No wireless networking hardware is expected on these hosts.
        WLAN = no;
        IPW2100_MONITOR = lib.mkForce unset;
        IPW2200_MONITOR = lib.mkForce unset;
        RT2800USB_RT53XX = lib.mkForce unset;
        RT2800USB_RT55XX = lib.mkForce unset;
        RTW88 = lib.mkForce unset;
        RTW88_8822BE = lib.mkForce unset;
        RTW88_8822CE = lib.mkForce unset;
        MT798X_WMAC = lib.mkForce unset;

        # Platform display glue that is not available once related platform
        # support is trimmed by this config.
        DRM_VC4_HDMI_CEC = lib.mkForce unset;

        # Game/controller input devices are not needed on servers.
        INPUT_JOYSTICK = lib.mkForce no;
        JOYSTICK_PSXPAD_SPI_FF = lib.mkForce unset;
        NVIDIA_SHIELD_FF = lib.mkForce unset;

        # InfiniBand/RDMA is not used by the infrastructure.
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
