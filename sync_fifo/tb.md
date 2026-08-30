# Sync FIFO Self-Checking TB

## Reference Model

使用：

- ref_fifo
- ref_wr_ptr
- ref_rd_ptr
- ref_count

不复制 DUT 的扩展指针实现。

## Reference Count

真正判断的是：

write_fire = wr_en && !full
read_fire  = rd_en && !empty

普通情况：

- 只写：+1
- 只读：-1
- 同时读写：不变

边界：

- Empty + 同时读写：0 → 1
- Full + 同时读写：16 → 15

## Expected 对齐

使用：

`expected`

和：

`expected_valid`

保证 DUT 的 `rd_data` 与参考结果逐笔比较。

## 核心理解

Self-checking TB：

Stimulus
→ Reference Model
→ Expected
→ Compare
→ PASS / ERROR
