from pathlib import Path
from pytest import fixture, FixtureRequest, TempPathFactory
from cocotb_test.simulator import Icarus
import sys

BASE_DIR = Path(__file__).parent.parent.parent.resolve()
VERILOG_SOURCES_DIR = BASE_DIR / "rtl"
TESTBENCH_DIR = Path(__file__).parent.resolve()
VERILOG_INCLUDES_DIR = BASE_DIR / "includes"
COMPILE_PARAMETERS_FILE = BASE_DIR / "verif" / "cfg" / "cmds.f"


@fixture(name="simulator", scope="function")
def cocotb_simulator(request: FixtureRequest):
    """Fixture to create cocotb_test Simulator instance object for RTL testbenchs"""

    module_name: str = request.function.__name__  # type: ignore
    workdir = BASE_DIR / "verif" /  "work" / f"cocotb_{module_name}"
    return Icarus(
        # Set working directory (simulation directory)
        sim_build=workdir,
        # Set language
        toplevel_lang="verilog",
        # Detect and include all verilog source files
        verilog_sources=[
            str(file)
            for file in VERILOG_SOURCES_DIR.rglob("*.v")
        ],
        # Detect and include all path containing cocotb tests
        python_search=[str(directory) for directory in TESTBENCH_DIR.rglob("./")],
        # Folder containing includes files
        includes=[str(VERILOG_INCLUDES_DIR)],
        # Verilog toplevel module name inferred from test name (strips test_ prefix)
        toplevel=module_name.partition("_")[-1],
        # Cocotb module name, literally the test name
        module=request.module.__name__,  # type: ignore
        # Compile all verilog sources before each test run
        force_compile=True,
        # Compile arguments
        compile_args=["-f", str(COMPILE_PARAMETERS_FILE)],
        # Enable wave dump
        waves=True,
        # Enable coverage
        coverage=True,
    )
