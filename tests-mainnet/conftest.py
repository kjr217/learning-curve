import pytest
import time
import constants
from brownie import (
    KernelFactory,
    LearningCurve,
    BasicERC20,
    accounts,
    web3,
    Wei,
    chain,
    Contract,
)


@pytest.fixture(scope="function", autouse=True)
def isolate_func(fn_isolation):
    # perform a chain rewind after completing each test, to ensure proper isolation
    # https://eth-brownie.readthedocs.io/en/v1.10.3/tests-pytest-intro.html#isolation-fixtures
    pass


@pytest.fixture(scope="function", autouse=True)
def contracts(deployer, kernelTreasury, dai, dai_whale):
    learning_curve = LearningCurve.deploy(dai.address, {"from": deployer})
    dai.transfer(deployer, 1e18, {"from": dai_whale})
    dai.approve(learning_curve, 1e18, {"from": deployer})
    learning_curve.initialise({"from": deployer})
    yield KernelFactory.deploy(
        dai.address,
        learning_curve.address,
        constants.VAULT,
        kernelTreasury.address,
        {"from": deployer}), \
        learning_curve

@pytest.fixture
def deployer(accounts):
    yield accounts[0]


@pytest.fixture
def steward(accounts):
    yield accounts[1]


@pytest.fixture
def learners(accounts):
    yield accounts[2:10]


@pytest.fixture
def dai():
    yield Contract.from_explorer("0x6B175474E89094C44Da98b954EedeAC495271d0F")


@pytest.fixture
def ydai():
    yield Contract.from_explorer("0x19D3364A399d251E894aC732651be8B0E4e85001")


@pytest.fixture
def dai_whale():
    yield accounts.at("0x47ac0Fb4F2D84898e4D9E7b4DaB3C24507a6D503", force=True)


@pytest.fixture
def gen_lev_strat():
    yield Contract.from_explorer("0x4031afd3B0F71Bace9181E554A9E680Ee4AbE7dF")

@pytest.fixture
def keeper():
    yield accounts.at("0xC3D6880fD95E06C816cB030fAc45b3ffe3651Cb0", force=True)


@pytest.fixture
def kernelTreasury(accounts):
    yield accounts.at("0x297a3C4B8bB87E671d31C475C5DbE434E24dFC1F", force=True)
