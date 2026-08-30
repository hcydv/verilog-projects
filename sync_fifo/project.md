# Sync FIFO

## 规格

- DATA_WIDTH = 8
- DEPTH = 16
- 单时钟 FIFO

## 核心结构

- Memory
- wr_ptr
- rd_ptr
- full
- empty

## 指针

Memory 地址：

`ptr[3:0]`

Wrap Bit：

`ptr[4]`

## Full / Empty

empty：

`wr_ptr == rd_ptr`

full：

低 4 位相同，最高位不同。

## 边界行为

- Full + Write → 拒绝写
- Empty + Read → 拒绝读
- 普通同时读写 → 数量不变
- Full + 同时读写 → 只读
- Empty + 同时读写 → 只写
