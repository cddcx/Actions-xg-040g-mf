#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# 说明:
#   - luci_npu feed 已从 feeds.conf.default 移除, 这里不再处理它。
#   - 保留 luci_airoha 整个 feed, 只用 luanmuc 的仓库替换其中的
#     luci-app-airoha-npu 包, 然后重建 luci_airoha 索引。
#   - clone 到 feeds/luci_airoha/<pkg>/ 子目录, 天然符合 scan.mk 结构。
#   - 本脚本在 "Update feeds" 之后执行, 故需手动重建索引。
#

# 1) 用 luanmuc 仓库替换 luci_airoha 下的同名 npu 包
echo "[diy-part2] Replacing luci-app-airoha-npu with luanmuc version ..."
rm -rf feeds/luci_airoha/luci-app-airoha-npu
git clone --depth=1 https://github.com/luanmuc/luci-app-airoha-npu.git \
  feeds/luci_airoha/luci-app-airoha-npu

if [ ! -f feeds/luci_airoha/luci-app-airoha-npu/Makefile ]; then
  echo "[diy-part2] ERROR: clone failed, Makefile missing!"
  exit 1
fi
rm -rf feeds/luci_airoha/luci-app-airoha-npu/.git
echo "[diy-part2] npu package replaced OK."

# 2) 重建 luci_airoha 索引 (update 阶段的旧索引还是原包信息)
echo "[diy-part2] Rebuilding luci_airoha index ..."
rm -rf feeds/luci_airoha.tmp
rm -f  feeds/luci_airoha.index feeds/luci_airoha.targetindex
./scripts/feeds update -i luci_airoha

# 3) 校验
if [ ! -e feeds/luci_airoha.index ]; then
  echo "[diy-part2] ERROR: luci_airoha.index still missing after rebuild!"
  exit 1
fi
if ! grep -q "Package: luci-app-airoha-npu" feeds/luci_airoha.index; then
  echo "[diy-part2] ERROR: luci-app-airoha-npu not found in index!"
  exit 1
fi
echo "[diy-part2] OK: luci_airoha index rebuilt, contains:"
grep "^Package:" feeds/luci_airoha.index | sed 's/^/    /'
