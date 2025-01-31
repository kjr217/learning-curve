import pytest
import constants_unit
from brownie import (
    KernelFactory,
    LearningCurve,
    BasicERC20,
)


@pytest.fixture(scope="function", autouse=True)
def isolate_func(fn_isolation):
    # perform a chain rewind after completing each test, to ensure proper isolation
    # https://eth-brownie.readthedocs.io/en/v1.10.3/tests-pytest-intro.html#isolation-fixtures
    pass


@pytest.fixture(scope="function", autouse=True)
def token(deployer):
    token = BasicERC20.deploy("Test", "TT", {"from": deployer})
    token.mint(1_000_000_000_000_000_000e18)
    yield token


@pytest.fixture(scope="function")
def contracts(deployer, token):
    learning_curve = LearningCurve.deploy(token.address, {"from": deployer})
    token.approve(learning_curve, 1e18, {"from": deployer})
    learning_curve.initialise({"from": deployer})
    yield KernelFactory.deploy(
        token.address,
        learning_curve.address,
        constants_unit.REGISTRY,
        {"from": deployer}), \
        learning_curve


@pytest.fixture(scope="function")
def contracts_with_courses(contracts, steward):
    kernel, learning_curve = contracts
    for n in range(5):
        tx = kernel.createCourse(
        constants_unit.FEE,
        constants_unit.CHECKPOINTS,
        constants_unit.CHECKPOINT_BLOCK_SPACING,
        constants_unit.URL,
        constants_unit.CREATOR,
        {"from": steward}
        )
    yield kernel, learning_curve


@pytest.fixture(scope="function")
def contracts_with_learners(contracts_with_courses, learners, token, deployer):
    kernel, learning_curve = contracts_with_courses
    for n, learner in enumerate(learners):
        token.transfer(learner, constants_unit.FEE, {"from": deployer})
        token.approve(kernel, constants_unit.FEE, {"from": learner})
        kernel.register(0, {"from": learner})
    yield kernel, learning_curve


@pytest.fixture
def deployer(accounts):
    yield accounts[0]


@pytest.fixture
def steward(accounts):
    yield accounts[1]


@pytest.fixture
def hackerman(accounts):
    yield accounts[9]


@pytest.fixture
def learners(accounts):
    yield accounts[2:8]


@pytest.fixture
def kernelTreasury(accounts):
    yield accounts.at("0x297a3C4B8bB87E671d31C475C5DbE434E24dFC1F", force=True)

