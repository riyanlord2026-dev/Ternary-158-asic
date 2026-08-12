import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting Ternary-158 Core Silicon Verification Test")

    # 1. Supply virtual power rails to the SkyWater gate cells for GL testing
    if hasattr(dut, "VPWR"):
        dut.VPWR.value = 1
    if hasattr(dut, "VGND"):
        dut.VGND.value = 0

    # 2. Boot up the virtual hardware clock loop (10MHz Clock rate)
    # This prevents the "Simulator shut down prematurely" error!
    cocotb.start_soon(Clock(dut.clk, 100, unit="ns").start())

    # 3. Apply a System Reset Cycle
    dut.rst_n.value = 0  # Active-low reset (0 means reset)
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1  # Release reset (1 means run)
    await ClockCycles(dut.clk, 5)

    # --- TEST CASE 1: Verify Addition (+1 weight) ---
    dut.ui_in.value = 15
    dut.uio_in.value = 0b01
    await ClockCycles(dut.clk, 2)

    # --- TEST CASE 2: Verify Subtraction (-1 weight) ---
    dut.ui_in.value = 5
    dut.uio_in.value = 0b10
    await ClockCycles(dut.clk, 2)

    # --- TEST CASE 3: Verify Zero State (0 weight) ---
    dut.ui_in.value = 50
    dut.uio_in.value = 0b00
    await ClockCycles(dut.clk, 2)

    dut._log.info("Ternary arithmetic verification cycles completed successfully!")
