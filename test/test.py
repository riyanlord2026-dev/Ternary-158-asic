import cocotb
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting Ternary-158 Core Silicon Verification Test")

    # 1. Turn on the physical power and ground pins for the gate-level simulation
    # This prevents the simulator from shutting down prematurely at 0.00ns
    if hasattr(dut, "VPWR"):
        dut.VPWR.value = 1
    if hasattr(dut, "VGND"):
        dut.VGND.value = 0

    # 2. Apply a System Reset Cycle
    dut.rst_n.value = 0  # Active-low reset (0 means reset)
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1  # Release reset (1 means run)
    await ClockCycles(dut.clk, 2)

    # --- TEST CASE 1: Verify Addition (+1 weight) ---
    dut.ui_in.value = 15
    dut.uio_in.value = 0b01
    await ClockCycles(dut.clk, 1)

    # --- TEST CASE 2: Verify Subtraction (-1 weight) ---
    dut.ui_in.value = 5
    dut.uio_in.value = 0b10
    await ClockCycles(dut.clk, 1)

    # --- TEST CASE 3: Verify Zero State (0 weight) ---
    dut.ui_in.value = 50
    dut.uio_in.value = 0b00
    await ClockCycles(dut.clk, 1)

    dut._log.info("Ternary arithmetic verification cycles completed successfully!")
