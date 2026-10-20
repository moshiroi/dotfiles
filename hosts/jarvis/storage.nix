{ pkgs, ... }:

let
  home = "/home/mohamedshire";
  bind = src: {
    device = src;
    fsType = "none";
    options = [ "bind" "nofail" ];
    depends = [ "/data" ];
  };
in
{
  # Dev drive (Crucial P1): XFS on LVM-VDO, which dedupes and LZ4-compresses
  # blocks underneath the filesystem. Worktrees and cargo target dirs are full
  # of identical blocks, so they collapse well. The OS drive stays plain ext4.
  services.lvm.package = pkgs.lvm2_vdo;
  environment.systemPackages = [ pkgs.vdo ];
  boot.kernelModules = [ "dm-vdo" ];

  # The pool is overcommitted (1.5T virtual on 931G physical); dmeventd logs a
  # warning as physical usage climbs, before writes start failing.
  services.lvm.dmeventd.enable = true;

  fileSystems."/data" = {
    device = "/dev/data/vdo";
    fsType = "xfs";
    options = [ "noatime" "nofail" ];
  };

  # Caches and SDK state are regenerable and dedupe well, so they live on /data
  # but stay at their usual paths: bind mounts, unlike symlinks, never leak the
  # real location into tools that key state by path.
  fileSystems."${home}/.cache" = bind "/data/.cache";
  fileSystems."${home}/.android" = bind "/data/.android";
  fileSystems."${home}/.gradle" = bind "/data/.gradle";
  fileSystems."${home}/.npm" = bind "/data/.npm";
  fileSystems."${home}/.local/share/containers" = bind "/data/.containers";

  # VDO only gets physical space back when the filesystem reports deletes, and
  # build dirs churn through gigabytes a day, so trim more often than weekly.
  services.fstrim.interval = "daily";
}
