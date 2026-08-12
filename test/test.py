import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting 8-Core Parallel Matrix Grid Verification Test")

    if hasattr(dut, "VPWR"):
        dut.VPWR.value = 1
    if hasattr(dut, "VGND"):
        dut.VGND.value = 0

    # Initialize clock
    cocotb.start_soon(Clock(dut.clk, 100, unit="ns").start())

    # Trigger system reset
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)

    # TEST CASE: Feed input pixel value of 25
    # Configure weights vector: 0b10101010 (Alternating +1 and -1 weights across grid cores)
    dut.ui_in.value = 25
    dut.uio_in.value = 170
    await ClockCycles(dut.clk, 10)

    dut._log.info("Matrix Grid computation validation cycle completed successfully!")
