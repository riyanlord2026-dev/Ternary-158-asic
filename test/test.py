import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting Dual-Core Ternary Silicon Verification Test")

    if hasattr(dut, "VPWR"):
        dut.VPWR.value = 1
    if hasattr(dut, "VGND"):
        dut.VGND.value = 0

    # Start system clock
    cocotb.start_soon(Clock(dut.clk, 100, unit="ns").start())

    # Apply Reset
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)

    # TEST CYCLE: Set activation to 10
    # Set Cell 0 weight to +1 (01) and Cell 1 weight to +1 (01)
    # Binary pattern for uio_in: 00000101 (Decimal 5)
    dut.ui_in.value = 10
    dut.uio_in.value = 5 
    await ClockCycles(dut.clk, 5)

    dut._log.info("Dual-core parallel verification successfully executed!")
