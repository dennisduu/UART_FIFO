import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
import random

@cocotb.test()
async def test_uart_fifo(dut):
    dut._log.info("Start UART+FIFO test")

    # Set the clock period to 10 ns (100 MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset the design
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)  # Hold reset for 10 clock cycles
    dut.rst_n.value = 1
    dut.ena.value = 1  # Enable the module

    # UART RX test - Send data into the FIFO
    for i in range(10):
        # Send random data into UART RX (uio_in)
        rx_data = random.randint(0, 255)
        dut.uio_in.value = rx_data

        # Wait for a few clock cycles to allow data to enter FIFO
        await ClockCycles(dut.clk, 10)

        dut._log.info(f"Sent {rx_data:02x} to UART RX")

    # UART TX test - Read data out of the FIFO via UART TX
    for i in range(10):
        # Wait for data to be ready on UART TX (uio_out)
        await RisingEdge(dut.uio_oe)  # Wait until TX line is enabled
        tx_data = dut.uio_out.value.integer

        dut._log.info(f"Received {tx_data:02x} from UART TX")
        await ClockCycles(dut.clk, 10)  # Wait between reads

    # Optional: Add more random test cases for edge case testing
    for i in range(1000):
        rx_data = random.randint(0, 255)
        dut.uio_in.value = rx_data
        await ClockCycles(dut.clk, 10)
        await RisingEdge(dut.uio_oe)
        tx_data = dut.uio_out.value.integer
        assert tx_data == rx_data, f"Data mismatch: Sent {rx_data:02x}, received {tx_data:02x}"
