//SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.4;
pragma abicoder v2;

import "./LearningCurve.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface I_Vault {
    function token() external view returns (address);
    function underlying() external view returns (address);
    function pricePerShare() external view returns (uint256);
    function deposit(uint256) external returns (uint256);
    function depositAll() external;
    function withdraw(uint256) external returns (uint256);
    function withdraw() external returns (uint256);
    function balanceOf(address) external returns (uint256);
}

interface I_LearningCurve {
    function mintForAddress(address, uint256) external;
    function balanceOf(address) external view returns (uint256);
}

/**
 * @title Kernel Factory
 * @author kjr217
 * @notice Deploys new courses and interacts with the learning curve directly to mint LEARN.
 */

contract KernelFactory {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    struct Course {
        uint256 checkpoints;            // number of checkpoints the course should have
        uint256 fee;                    // the fee for entering the course
        uint256 checkpointBlockSpacing; // the block spacing between checkpoints
        string url;                     // url containing course data
        address treasuryAddress;        // address to receive any yield from a redeem call
    }

    struct Learner {
        uint256 blockRegistered;        // used to decide when a learner can claim their registration fee back
        uint256 yieldBatchId;           // the batch id for this learner's Yield bearing deposit
        uint256 checkpointReached;      // what checkpoint the learner has reached
    }

    // containing course data mapped by a courseId
    mapping(uint256 => Course) public courses;
    // containing learner data mapped by a courseId and address
    mapping(uint256 => mapping (address => Learner)) learnerData;

    // containing the total underlying amount for a yield batch mapped by batchId
    mapping(uint256 => uint256) batchTotal;
    // containing the total amount of yield token for a yield batch mapped by batchId
    mapping(uint256 => uint256) batchYieldTotal;
    // containing the underlying amount a learner deposited in a specific batchId
    mapping(uint256 => mapping (address => uint256)) learnerDeposit;
    // tracker for the batchId, current represents the current batch
    Counters.Counter private batchIdTracker;
    // the stablecoin used by the contract, DAI
    IERC20 public stable;
    // the yearn vault used by the contract, yDAI
    I_Vault public vault;
    // yield rewards for an eligible address
    mapping(address => uint256) yieldRewards;

    // tracker for the courseId, current represents the id of the next course
    Counters.Counter private courseIdTracker;
    // interface for the learning curve
    I_LearningCurve public learningCurve;


    event CourseCreated(
        uint256 indexed courseId,
        uint256 checkpoints,
        uint256 fee,
        uint256 checkpointBlockSpacing,
        string url,
        address treasuryAddress
    );

    event LearnerRegistered(
        uint256 indexed courseId,
        address learner
    );
    event FeeRedeemed(
        uint256 courseId,
        address learner,
        uint256 amount
    );
    event LearnMintedFromCourse(
        uint256 courseId,
        address learner,
        uint256 stableConverted,
        uint256 learnMinted
    );
    event BatchDeposited(
        uint256 batchId,
        uint256 batchAmount,
        uint256 batchYieldAmount
    );
    event CheckpointUpdated(
        uint256 courseId,
        uint256 checkpointReached,
        address learner
    );
    event YieldRewardRedeemed(
        address redeemer,
        uint256 yieldRewarded
    );

    constructor(
        address _stable,
        address _learningCurve,
        address _vault
    ) {
        stable = IERC20(_stable);
        learningCurve = I_LearningCurve(_learningCurve);
        vault = I_Vault(_vault);
    }

    /**
     * @notice                         create a course
     * @param  _fee                    fee for a learner to register
     * @param  _checkpoints            number of checkpoints on the course
     * @param  _checkpointBlockSpacing block spacing between subsequent checkpoints
     * @param  _url                    url leading to course details
     * @param  _treasuryAddress        the address that excess yield will be sent to on a redeem
     */
    function createCourse(
        uint256 _fee,
        uint256 _checkpoints,
        uint256 _checkpointBlockSpacing,
        string calldata _url,
        address _treasuryAddress
    ) external {
        require(_fee > 0, "createCourse: fee must be greater than 0");
        require(_checkpointBlockSpacing > 0,
            "createCourse: checkpointBlockSpacing must be greater than 0");
        require(_checkpoints > 0, "createCourse: checkpoint must be greater than 0");
        require(_treasuryAddress != address(0), "createCourse: treasuryAddress cannot be 0 address");
        uint256 courseId_ = courseIdTracker.current();
        courseIdTracker.increment();
        courses[courseId_] = Course(
                                  _checkpoints,
                                  _fee,
                                  _checkpointBlockSpacing,
                                  _url,
                                  _treasuryAddress
                                 );
        emit CourseCreated(
                            courseId_,
                            _checkpoints,
                            _fee,
                            _checkpointBlockSpacing,
                            _url,
                            _treasuryAddress
        );
    }

    /**
     * @notice deposit the current batch of DAI in the contract to yearn
     */
    function batchDeposit() external {
        uint256 batchId_ = batchIdTracker.current();
        // initiate the next batch
        uint256 batchAmount_ = batchTotal[batchId_];
        batchIdTracker.increment();
        require(batchAmount_ > 0, "batchDeposit: no funds to deposit");
        // approve the vault
        stable.approve(address(vault), batchAmount_);
        // mint y from the vault
        uint256 yTokens = vault.deposit(batchAmount_);
        batchYieldTotal[batchId_] = yTokens;

        emit BatchDeposited(batchId_, batchAmount_, yTokens);
    }

    /**
     * @notice handles learner registration
     * @param  _courseId course id the learner would like to register to
     */
     function register(uint256 _courseId) public {
         require(_courseId < courseIdTracker.current(), "register: courseId does not exist");
         uint256 batchId_ = batchIdTracker.current();
         require(learnerData[_courseId][msg.sender].blockRegistered == 0, "register: already registered");
         Course storage course = courses[_courseId];

         stable.safeTransferFrom(msg.sender, address(this), course.fee);

         learnerData[_courseId][msg.sender].blockRegistered = block.number;
         learnerData[_courseId][msg.sender].yieldBatchId = batchId_;
         batchTotal[batchId_] += course.fee;
         learnerDeposit[batchId_][msg.sender] += course.fee;

         emit LearnerRegistered(_courseId, msg.sender);
     }

    /**
     * @notice           handles checkpoint verification
     *                   All course are deployed with a given number of checkpoints
     *                   allowing learners to receive a portion of their fees back
     *                   at various stages in the course.
     *
     *                   This is a helper function that checks where a learner is
     *                   in a course and is used by both redeem() and mint() to figure out
     *                   the proper amount required.
     *
     * @param  learner   address of the learner to verify
     * @param  _courseId course id to verify for the learner
     * @return           the checkpoint that the learner has reached
     */
     function verify (address learner, uint256 _courseId) public view returns (uint256) {
         require(_courseId < courseIdTracker.current(), "verify: courseId does not exist");
         require(learnerData[_courseId][learner].blockRegistered != 0, "verify: not registered to this course");
         return _verify(learner, _courseId);
     }

    /**
     * @notice                   handles checkpoint verification
     *                           All course are deployed with a given number of checkpoints
     *                           allowing learners to receive a portion of their fees back
     *                           at various stages in the course.
     *
     *                           This is a helper function that checks where a learner is
     *                           in a course and is used by both redeem() and mint() to figure out
     *                           the proper amount required.
     *
     * @param  learner           address of the learner to verify
     * @param  _courseId         course id to verify for the learner
     * @return checkpointReached the checkpoint that the learner has reached.
     */
     function _verify(address learner, uint256 _courseId) internal view returns (uint256 checkpointReached){
         uint256 blocksSinceRegister = block.number - learnerData[_courseId][learner].blockRegistered;
         checkpointReached = blocksSinceRegister / courses[_courseId].checkpointBlockSpacing;
         if (courses[_courseId].checkpoints < checkpointReached){
             checkpointReached = courses[_courseId].checkpoints;
         }
     }

     /**
     * @notice           handles fee redemption into stable
     *                   if a learner is redeeming rather than minting, it means
     *                   they are simply requesting their initial fee back (whether
     *                   they have completed the course or not).
     *                   In this case, it checks what proportion of `fee` (set when
     *                   the course is deployed) must be returned and sends it back
     *                   to the learner.
     *
     *                   Whatever yield they earned is sent to the course configured address.
     *
     *                   If the learner has not completed the course, it checks that ~6months
     *                   have elapsed since blockRegistered, at which point the full `fee`
     *                   can be returned and the yield sent to the course configured address.
     *
     * @param  _courseId course id to redeem the fee from
     */
     function redeem(uint256 _courseId) external {
         uint256 shares;
         uint256 learnerShares;
         bool deployed;
         require(learnerData[_courseId][msg.sender].blockRegistered != 0, "redeem: not a learner on this course");
         uint256 checkpointReached = learnerData[_courseId][msg.sender].checkpointReached;
         (learnerShares, deployed) = getEligibleAmount(_courseId);
         uint256 latestCheckpoint = learnerData[_courseId][msg.sender].checkpointReached;
         if (deployed){
             shares = vault.withdraw(learnerShares);
             uint256 fee_ = (latestCheckpoint - checkpointReached)
                                           * (courses[_courseId].fee / courses[_courseId].checkpoints);
             if (fee_ < shares){
                 yieldRewards[courses[_courseId].treasuryAddress] += shares - fee_;
                 stable.safeTransfer(msg.sender, fee_);
                 emit FeeRedeemed(_courseId, msg.sender, fee_);
             } else {
                 stable.safeTransfer(msg.sender, shares);
                 emit FeeRedeemed(_courseId, msg.sender, shares);
             }
         } else {
             stable.safeTransfer(msg.sender, learnerShares);
             emit FeeRedeemed(_courseId, msg.sender, learnerShares);
         }
     }

    /**
     * @notice           handles learner minting new LEARN
     *                   checks via verify() what proportion of the fee to send to the
     *                   Learning Curve, adds any yield earned to that, and returns all
     *                   the resulting LEARN tokens to the learner.
     *
     *                   This acts as an effective discount for learners (as they receive more LEARN)
     *                   without us having to maintain a whitelist or the like: great for simplicity,
     *                   security and usability.
     *
     * @param  _courseId course id to mint LEARN from
     */
    function mint(uint256 _courseId) external {
        uint256 shares;
        bool deployed;
        require(learnerData[_courseId][msg.sender].blockRegistered != 0, "mint: not a learner on this course");
        (shares, deployed) = getEligibleAmount(_courseId);
        if (deployed){
            shares = vault.withdraw(shares);
        }
        stable.approve(address(learningCurve), shares);
        uint256 balanceBefore = learningCurve.balanceOf(msg.sender);
        learningCurve.mintForAddress(msg.sender, shares);
        emit LearnMintedFromCourse(_courseId, msg.sender, shares, learningCurve.balanceOf(msg.sender) - balanceBefore);
     }

    /**
     * @notice Gets the amount of dai that an address is eligible, addresses become eligible if
     *         they are the designated reward receiver for a specific course and a learner on that
     *         course decided to redeem, meaning yield was reserved for the rewward receiver
     */
    function withdrawYieldRewards() external{
        uint256 withdrawableReward = getYieldRewards(msg.sender);
        yieldRewards[msg.sender] = 0;
        stable.safeTransfer(msg.sender, withdrawableReward);
        emit YieldRewardRedeemed(msg.sender, withdrawableReward);
    }

    /**
     * @notice                gets the amount of funds that a learner is eligible for at this timestamp
     * @param  _courseId      course id to mint LEARN from
     * @return eligibleShares the number of shares the learner can withdraw
     *                        (if bool deployed is true will return yDai amount, if it is false it will
     *                        return the Dai amount)
     * @return deployed       whether the funds to be redeemed were deployed to yearn
     */
    function getEligibleAmount(uint256 _courseId) internal returns (uint256 eligibleShares, bool deployed){
        uint256 fee = learnerDeposit[_courseId][msg.sender];
        require(fee > 0, "no fee to redeem");
        uint256 checkpointReached = verify(msg.sender, _courseId);
        require(checkpointReached > learnerData[_courseId][msg.sender].checkpointReached,
            "fee redeemed at this checkpoint");
        uint256 eligibleAmount = (checkpointReached
            - learnerData[_courseId][msg.sender].checkpointReached)
            * (courses[_courseId].fee / courses[_courseId].checkpoints);

        learnerData[_courseId][msg.sender].checkpointReached = checkpointReached;

        emit CheckpointUpdated(_courseId, checkpointReached, msg.sender);

        if (eligibleAmount > fee){
            eligibleAmount = fee;
        }
        uint256 batchId_ = learnerData[_courseId][msg.sender].yieldBatchId;
        if (batchId_ == batchIdTracker.current()){
            deployed = false;
            eligibleShares = eligibleAmount;
        } else {
            uint256 temp =  (eligibleAmount * 1e18) / batchTotal[batchId_];
            deployed = true;
            eligibleShares = (temp * batchYieldTotal[batchId_]) / 1e18;
        }
        learnerDeposit[_courseId][msg.sender] -= eligibleAmount;
    }

    function getCurrentBatchTotal() external view returns(uint256){
        return batchTotal[batchIdTracker.current()];
    }

    function getBlockRegistered(address learner, uint256 courseId) external view returns (uint256){
        return learnerData[courseId][learner].blockRegistered;
    }

    function getCurrentBatchId() external view returns (uint256){
        return batchIdTracker.current();
    }

    function getNextCourseId() external view returns (uint256){
        return courseIdTracker.current();
    }

    /// @dev rough calculation used for frontend work
    function getLearnerCourseEligibleFunds(address learner, uint256 _courseId) external view returns (uint256){
        uint256 checkPointReached = verify(learner, _courseId);
        uint256 checkPointRedeemed = learnerData[_courseId][learner].checkpointReached;
        if (checkPointReached <= checkPointRedeemed){
            return 0;
        }
        uint256 batchId_ = learnerData[_courseId][msg.sender].yieldBatchId;
        uint256 eligibleFunds = (courses[_courseId].fee / courses[_courseId].checkpoints) * (checkPointReached - checkPointRedeemed);
        if (batchId_ == batchIdTracker.current()){
            return eligibleFunds;
        } else {
            uint256 temp =  (eligibleFunds * 1e18) / batchTotal[batchId_];
            uint256 eligibleShares = (temp * batchYieldTotal[batchId_]) / 1e18;
            return eligibleShares * vault.pricePerShare() / 1e18;
        }
    }

    /// @dev rough calculation used for frontend work
    function getLearnerCourseFundsRemaining(address learner, uint256 _courseId) external view returns (uint256){
        uint256 checkPointReached = verify(learner, _courseId);
        uint256 checkPointRedeemed = learnerData[_courseId][learner].checkpointReached;
        uint256 batchId_ = learnerData[_courseId][msg.sender].yieldBatchId;
        uint256 eligibleFunds = (courses[_courseId].fee / courses[_courseId].checkpoints) * (courses[_courseId].checkpoints - checkPointRedeemed);
        if (batchId_ == batchIdTracker.current()){
            return eligibleFunds;
        } else {
            uint256 temp =  (eligibleFunds * 1e18) / batchTotal[batchId_];
            uint256 eligibleShares = (temp * batchYieldTotal[batchId_]) / 1e18;
            return eligibleShares * vault.pricePerShare() / 1e18;
        }
    }

    function getCourseUrl(uint256 _courseId) external view returns (string memory){
        return courses[_courseId].url;
    }

    function getYieldRewards(address redeemer) public view returns (uint256){
        return yieldRewards[redeemer];
    }
}