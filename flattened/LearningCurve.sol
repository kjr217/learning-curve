// SPDX-License-Identifier: MPL-2.0

pragma solidity 0.8.0;



// Part: Counters

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// Part: DaiPermit

interface DaiPermit {

    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    //EIP2612 implementation
    function permit(
        address holder,
        address spender,
        uint256 amount,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address holder) external view returns(uint);

    function pull(address usr, uint256 wad) external;

    function approve(address usr, uint256 wad) external returns (bool);
}

// Part: IERC20Permit

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// Part: OpenZeppelin/openzeppelin-contracts@4.0.0/Address

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// Part: OpenZeppelin/openzeppelin-contracts@4.0.0/Context

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// Part: OpenZeppelin/openzeppelin-contracts@4.0.0/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Part: PRBMath

/// @dev Common mathematical functions used in both PRBMathSD59x18 and PRBMathUD60x18. Note that this shared library
/// does not always assume the signed 59.18-decimal fixed-point or the unsigned 60.18-decimal fixed-point
// representation. When it does not, it is annonated in the function's NatSpec documentation.
library PRBMath {
    /// STRUCTS ///

    struct SD59x18 {
        int256 value;
    }

    struct UD60x18 {
        uint256 value;
    }

    /// STORAGE ///

    /// @dev How many trailing decimals can be represented.
    uint256 internal constant SCALE = 1e18;

    /// @dev Largest power of two divisor of SCALE.
    uint256 internal constant SCALE_LPOTD = 262144;

    /// @dev SCALE inverted mod 2^256.
    uint256 internal constant SCALE_INVERSE =
        78156646155174841979727994598816262306175212592076161876661508869554232690281;

    /// @notice Calculates the binary exponent of x using the binary fraction method.
    /// @dev Uses 128.128-bit fixed-point numbers, which is the most efficient way.
    /// See https://ethereum.stackexchange.com/a/96594/24693.
    /// @param x The exponent as an unsigned 128.128-bit fixed-point number.
    /// @return result The result as an unsigned 60x18 decimal fixed-point number.
    function exp2(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            // Start from 0.5 in the 128.128-bit fixed-point format.
            result = 0x80000000000000000000000000000000;

            // Multiply the result by root(2, 2^-i) when the bit at position i is 1. None of the intermediary results overflows
            // because the initial result is 2^127 and all magic factors are less than 2^129.
            if (x & 0x80000000000000000000000000000000 > 0)
                result = (result * 0x16A09E667F3BCC908B2FB1366EA957D3E) >> 128;
            if (x & 0x40000000000000000000000000000000 > 0)
                result = (result * 0x1306FE0A31B7152DE8D5A46305C85EDED) >> 128;
            if (x & 0x20000000000000000000000000000000 > 0)
                result = (result * 0x1172B83C7D517ADCDF7C8C50EB14A7920) >> 128;
            if (x & 0x10000000000000000000000000000000 > 0)
                result = (result * 0x10B5586CF9890F6298B92B71842A98364) >> 128;
            if (x & 0x8000000000000000000000000000000 > 0)
                result = (result * 0x1059B0D31585743AE7C548EB68CA417FE) >> 128;
            if (x & 0x4000000000000000000000000000000 > 0)
                result = (result * 0x102C9A3E778060EE6F7CACA4F7A29BDE9) >> 128;
            if (x & 0x2000000000000000000000000000000 > 0)
                result = (result * 0x10163DA9FB33356D84A66AE336DCDFA40) >> 128;
            if (x & 0x1000000000000000000000000000000 > 0)
                result = (result * 0x100B1AFA5ABCBED6129AB13EC11DC9544) >> 128;
            if (x & 0x800000000000000000000000000000 > 0)
                result = (result * 0x10058C86DA1C09EA1FF19D294CF2F679C) >> 128;
            if (x & 0x400000000000000000000000000000 > 0)
                result = (result * 0x1002C605E2E8CEC506D21BFC89A23A011) >> 128;
            if (x & 0x200000000000000000000000000000 > 0)
                result = (result * 0x100162F3904051FA128BCA9C55C31E5E0) >> 128;
            if (x & 0x100000000000000000000000000000 > 0)
                result = (result * 0x1000B175EFFDC76BA38E31671CA939726) >> 128;
            if (x & 0x80000000000000000000000000000 > 0)
                result = (result * 0x100058BA01FB9F96D6CACD4B180917C3E) >> 128;
            if (x & 0x40000000000000000000000000000 > 0)
                result = (result * 0x10002C5CC37DA9491D0985C348C68E7B4) >> 128;
            if (x & 0x20000000000000000000000000000 > 0)
                result = (result * 0x1000162E525EE054754457D5995292027) >> 128;
            if (x & 0x10000000000000000000000000000 > 0)
                result = (result * 0x10000B17255775C040618BF4A4ADE83FD) >> 128;
            if (x & 0x8000000000000000000000000000 > 0)
                result = (result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAC) >> 128;
            if (x & 0x4000000000000000000000000000 > 0)
                result = (result * 0x100002C5C89D5EC6CA4D7C8ACC017B7CA) >> 128;
            if (x & 0x2000000000000000000000000000 > 0)
                result = (result * 0x10000162E43F4F831060E02D839A9D16D) >> 128;
            if (x & 0x1000000000000000000000000000 > 0)
                result = (result * 0x100000B1721BCFC99D9F890EA06911763) >> 128;
            if (x & 0x800000000000000000000000000 > 0)
                result = (result * 0x10000058B90CF1E6D97F9CA14DBCC1629) >> 128;
            if (x & 0x400000000000000000000000000 > 0)
                result = (result * 0x1000002C5C863B73F016468F6BAC5CA2C) >> 128;
            if (x & 0x200000000000000000000000000 > 0)
                result = (result * 0x100000162E430E5A18F6119E3C02282A6) >> 128;
            if (x & 0x100000000000000000000000000 > 0)
                result = (result * 0x1000000B1721835514B86E6D96EFD1BFF) >> 128;
            if (x & 0x80000000000000000000000000 > 0)
                result = (result * 0x100000058B90C0B48C6BE5DF846C5B2F0) >> 128;
            if (x & 0x40000000000000000000000000 > 0)
                result = (result * 0x10000002C5C8601CC6B9E94213C72737B) >> 128;
            if (x & 0x20000000000000000000000000 > 0)
                result = (result * 0x1000000162E42FFF037DF38AA2B219F07) >> 128;
            if (x & 0x10000000000000000000000000 > 0)
                result = (result * 0x10000000B17217FBA9C739AA5819F44FA) >> 128;
            if (x & 0x8000000000000000000000000 > 0)
                result = (result * 0x1000000058B90BFCDEE5ACD3C1CEDC824) >> 128;
            if (x & 0x4000000000000000000000000 > 0)
                result = (result * 0x100000002C5C85FE31F35A6A30DA1BE51) >> 128;
            if (x & 0x2000000000000000000000000 > 0)
                result = (result * 0x10000000162E42FF0999CE3541B9FFFD0) >> 128;
            if (x & 0x1000000000000000000000000 > 0)
                result = (result * 0x100000000B17217F80F4EF5AADDA45554) >> 128;
            if (x & 0x800000000000000000000000 > 0)
                result = (result * 0x10000000058B90BFBF8479BD5A81B51AE) >> 128;
            if (x & 0x400000000000000000000000 > 0)
                result = (result * 0x1000000002C5C85FDF84BD62AE30A74CD) >> 128;
            if (x & 0x200000000000000000000000 > 0)
                result = (result * 0x100000000162E42FEFB2FED257559BDAA) >> 128;
            if (x & 0x100000000000000000000000 > 0)
                result = (result * 0x1000000000B17217F7D5A7716BBA4A9AF) >> 128;
            if (x & 0x80000000000000000000000 > 0)
                result = (result * 0x100000000058B90BFBE9DDBAC5E109CCF) >> 128;
            if (x & 0x40000000000000000000000 > 0)
                result = (result * 0x10000000002C5C85FDF4B15DE6F17EB0E) >> 128;
            if (x & 0x20000000000000000000000 > 0)
                result = (result * 0x1000000000162E42FEFA494F1478FDE05) >> 128;
            if (x & 0x10000000000000000000000 > 0)
                result = (result * 0x10000000000B17217F7D20CF927C8E94D) >> 128;
            if (x & 0x8000000000000000000000 > 0)
                result = (result * 0x1000000000058B90BFBE8F71CB4E4B33E) >> 128;
            if (x & 0x4000000000000000000000 > 0)
                result = (result * 0x100000000002C5C85FDF477B662B26946) >> 128;
            if (x & 0x2000000000000000000000 > 0)
                result = (result * 0x10000000000162E42FEFA3AE53369388D) >> 128;
            if (x & 0x1000000000000000000000 > 0)
                result = (result * 0x100000000000B17217F7D1D351A389D41) >> 128;
            if (x & 0x800000000000000000000 > 0)
                result = (result * 0x10000000000058B90BFBE8E8B2D3D4EDF) >> 128;
            if (x & 0x400000000000000000000 > 0)
                result = (result * 0x1000000000002C5C85FDF4741BEA6E77F) >> 128;
            if (x & 0x200000000000000000000 > 0)
                result = (result * 0x100000000000162E42FEFA39FE95583C3) >> 128;
            if (x & 0x100000000000000000000 > 0)
                result = (result * 0x1000000000000B17217F7D1CFB72B45E3) >> 128;
            if (x & 0x80000000000000000000 > 0)
                result = (result * 0x100000000000058B90BFBE8E7CC35C3F2) >> 128;
            if (x & 0x40000000000000000000 > 0)
                result = (result * 0x10000000000002C5C85FDF473E242EA39) >> 128;
            if (x & 0x20000000000000000000 > 0)
                result = (result * 0x1000000000000162E42FEFA39F02B772C) >> 128;
            if (x & 0x10000000000000000000 > 0)
                result = (result * 0x10000000000000B17217F7D1CF7D83C1A) >> 128;
            if (x & 0x8000000000000000000 > 0)
                result = (result * 0x1000000000000058B90BFBE8E7BDCBE2E) >> 128;
            if (x & 0x4000000000000000000 > 0)
                result = (result * 0x100000000000002C5C85FDF473DEA871F) >> 128;
            if (x & 0x2000000000000000000 > 0)
                result = (result * 0x10000000000000162E42FEFA39EF44D92) >> 128;
            if (x & 0x1000000000000000000 > 0)
                result = (result * 0x100000000000000B17217F7D1CF79E949) >> 128;
            if (x & 0x800000000000000000 > 0)
                result = (result * 0x10000000000000058B90BFBE8E7BCE545) >> 128;
            if (x & 0x400000000000000000 > 0)
                result = (result * 0x1000000000000002C5C85FDF473DE6ECA) >> 128;
            if (x & 0x200000000000000000 > 0)
                result = (result * 0x100000000000000162E42FEFA39EF366F) >> 128;
            if (x & 0x100000000000000000 > 0)
                result = (result * 0x1000000000000000B17217F7D1CF79AFA) >> 128;
            if (x & 0x80000000000000000 > 0)
                result = (result * 0x100000000000000058B90BFBE8E7BCD6E) >> 128;
            if (x & 0x40000000000000000 > 0)
                result = (result * 0x10000000000000002C5C85FDF473DE6B3) >> 128;
            if (x & 0x20000000000000000 > 0)
                result = (result * 0x1000000000000000162E42FEFA39EF359) >> 128;
            if (x & 0x10000000000000000 > 0)
                result = (result * 0x10000000000000000B17217F7D1CF79AC) >> 128;

            // We're doing two things at the same time:
            //
            //   1. Multiply the result by 2^n + 1, where 2^n is the integer part and 1 is an extra bit to account
            //      for the fact that we initially set the result to 0.5 We implement this by subtracting from 127
            //      instead of 128.
            //   2. Convert the result to the unsigned 60.18-decimal fixed-point format.
            //
            // This works because result * SCALE * 2^ip / 2^127 = result * SCALE / 2^(127 - ip), where ip is the integer
            // part and SCALE / 2^128 is what converts the result to the unsigned fixed-point format.
            result *= SCALE;
            result >>= (127 - (x >> 128));
        }
    }

    /// @notice Finds the zero-based index of the first one in the binary representation of x.
    /// @dev See the note on msb in the "Find First Set" Wikipedia article https://en.wikipedia.org/wiki/Find_first_set
    /// @param x The uint256 number for which to find the index of the most significant bit.
    /// @return msb The index of the most significant bit as an uint256.
    function mostSignificantBit(uint256 x) internal pure returns (uint256 msb) {
        if (x >= 2**128) {
            x >>= 128;
            msb += 128;
        }
        if (x >= 2**64) {
            x >>= 64;
            msb += 64;
        }
        if (x >= 2**32) {
            x >>= 32;
            msb += 32;
        }
        if (x >= 2**16) {
            x >>= 16;
            msb += 16;
        }
        if (x >= 2**8) {
            x >>= 8;
            msb += 8;
        }
        if (x >= 2**4) {
            x >>= 4;
            msb += 4;
        }
        if (x >= 2**2) {
            x >>= 2;
            msb += 2;
        }
        if (x >= 2**1) {
            // No need to shift x any more.
            msb += 1;
        }
    }

    /// @notice Calculates floor(x*y÷denominator) with full precision.
    ///
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv.
    ///
    /// Requirements:
    /// - The denominator cannot be zero.
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    /// @param x The multiplicand as an uint256.
    /// @param y The multiplier as an uint256.
    /// @param denominator The divisor as an uint256.
    /// @return result The result as an uint256.
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2**256 and mod 2**256 - 1, then use
        // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0.
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        // Make sure the result is less than 2**256. Also prevents denominator == 0.
        require(denominator > prod1);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0].
        uint256 remainder;
        assembly {
            // Compute remainder using mulmod.
            remainder := mulmod(x, y, denominator)

            // Subtract 256 bit number from 512 bit number
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
        // See https://cs.stackexchange.com/q/138556/92363.
        unchecked {
            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by lpotdod.
                denominator := div(denominator, lpotdod)

                // Divide [prod1 prod0] by lpotdod.
                prod0 := div(prod0, lpotdod)

                // Flip lpotdod such that it is 2**256 / lpotdod. If lpotdod is zero, then it becomes one.
                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * lpotdod;

            // Invert denominator mod 2**256. Now that denominator is an odd number, it has an inverse modulo 2**256 such
            // that denominator * inv = 1 mod 2**256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inverse = (3 * denominator) ^ 2;

            // Now use Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2**8
            inverse *= 2 - denominator * inverse; // inverse mod 2**16
            inverse *= 2 - denominator * inverse; // inverse mod 2**32
            inverse *= 2 - denominator * inverse; // inverse mod 2**64
            inverse *= 2 - denominator * inverse; // inverse mod 2**128
            inverse *= 2 - denominator * inverse; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2**256. Since the precoditions guarantee that the outcome is
            // less than 2**256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /// @notice Calculates floor(x*y÷1e18) with full precision.
    ///
    /// @dev Variant of "mulDiv" with constant folding, i.e. in which the denominator is always 1e18. Before returning the
    /// final result, we add 1 if (x * y) % SCALE >= HALF_SCALE. Without this, 6.6e-19 would be truncated to 0 instead of
    /// being rounded to 1e-18.  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717.
    ///
    /// Requirements:
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - The body is purposely left uncommented; see the NatSpec comments in "PRBMath.mulDiv" to understand how this works.
    /// - It is assumed that the result can never be type(uint256).max when x and y solve the following two queations:
    ///     1. x * y = type(uint256).max * SCALE
    ///     2. (x * y) % SCALE >= SCALE / 2
    ///
    /// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function mulDivFixedPoint(uint256 x, uint256 y)
        internal
        pure
        returns (uint256 result)
    {
        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        uint256 remainder;
        uint256 roundUpUnit;
        assembly {
            remainder := mulmod(x, y, SCALE)
            roundUpUnit := gt(remainder, 499999999999999999)
        }

        if (prod1 == 0) {
            unchecked {
                result = (prod0 / SCALE) + roundUpUnit;
                return result;
            }
        }

        require(SCALE > prod1);

        assembly {
            result := add(
                mul(
                    or(
                        div(sub(prod0, remainder), SCALE_LPOTD),
                        mul(
                            sub(prod1, gt(remainder, prod0)),
                            add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1)
                        )
                    ),
                    SCALE_INVERSE
                ),
                roundUpUnit
            )
        }
    }

    /// @notice Calculates floor(x*y÷denominator) with full precision.
    ///
    /// @dev An extension of "mulDiv" for signed numbers. Works by computing the signs and the absolute values separately.
    ///
    /// Requirements:
    /// - None of the inputs can be type(int256).min.
    /// - The result must fit within int256.
    ///
    /// @param x The multiplicand as an int256.
    /// @param y The multiplier as an int256.
    /// @param denominator The divisor as an int256.
    /// @return result The result as an int256.
    function mulDivSigned(
        int256 x,
        int256 y,
        int256 denominator
    ) internal pure returns (int256 result) {
        require(x > type(int256).min);
        require(y > type(int256).min);
        require(denominator > type(int256).min);

        // Get hold of the absolute values of x, y and the denominator.
        uint256 ax;
        uint256 ay;
        uint256 ad;
        unchecked {
            ax = x < 0 ? uint256(-x) : uint256(x);
            ay = y < 0 ? uint256(-y) : uint256(y);
            ad = denominator < 0 ? uint256(-denominator) : uint256(denominator);
        }

        // Compute the absolute value of (x*y)÷denominator. The result must fit within int256.
        uint256 resultUnsigned = mulDiv(ax, ay, ad);
        require(resultUnsigned <= uint256(type(int256).max));

        // Get the signs of x, y and the denominator.
        uint256 sx;
        uint256 sy;
        uint256 sd;
        assembly {
            sx := sgt(x, sub(0, 1))
            sy := sgt(y, sub(0, 1))
            sd := sgt(denominator, sub(0, 1))
        }

        // XOR over sx, sy and sd. This is checking whether there are one or three negative signs in the inputs.
        // If yes, the result should be negative.
        result = sx ^ sy ^ sd == 0
            ? -int256(resultUnsigned)
            : int256(resultUnsigned);
    }

    /// @notice Calculates the square root of x, rounding down.
    /// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    /// @param x The uint256 number for which to calculate the square root.
    /// @return result The result as an uint256.
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Set the initial guess to the closest power of two that is higher than x.
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }
}

// Part: Strings

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// Part: ECDSA

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// Part: OpenZeppelin/openzeppelin-contracts@4.0.0/ERC20

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overloaded;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// Part: OpenZeppelin/openzeppelin-contracts@4.0.0/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// Part: PRBMathUD60x18

/// @title PRBMathUD60x18
/// @author Paul Razvan Berg
/// @notice Smart contract library for advanced fixed-point math. It works with uint256 numbers considered to have 18
/// trailing decimals. We call this number representation unsigned 60.18-decimal fixed-point, since there can be up to 60
/// digits in the integer part and up to 18 decimals in the fractional part. The numbers are bound by the minimum and the
/// maximum values permitted by the Solidity type uint256.
library PRBMathUD60x18 {
    /// STORAGE ///

    /// @dev Half the SCALE number.
    uint256 internal constant HALF_SCALE = 5e17;

    /// @dev log2(e) as an unsigned 60.18-decimal fixed-point number.
    uint256 internal constant LOG2_E = 1442695040888963407;

    /// @dev The maximum value an unsigned 60.18-decimal fixed-point number can have.
    uint256 internal constant MAX_UD60x18 =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    /// @dev The maximum whole value an unsigned 60.18-decimal fixed-point number can have.
    uint256 internal constant MAX_WHOLE_UD60x18 =
        115792089237316195423570985008687907853269984665640564039457000000000000000000;

    /// @dev How many trailing decimals can be represented.
    uint256 internal constant SCALE = 1e18;

    /// @notice Adds two unsigned 60.18-decimal fixed-point numbers together, returning a new unsigned 60.18-decimal
    /// fixed-point number.
    /// @param x The first unsigned 60.18-decimal fixed-point number to add.
    /// @param y The second unsigned 60.18-decimal fixed-point number to add.
    /// @param result The result as an unsigned 59.18 decimal fixed-point number.
    function add(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        unchecked {
            uint256 rValue = x.value + y.value;
            require(rValue >= x.value);
            result = PRBMath.UD60x18({value: rValue});
        }
    }

    /// @notice Calculates arithmetic average of x and y, rounding down.
    /// @param x The first operand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The second operand as an unsigned 60.18-decimal fixed-point number.
    /// @return result The arithmetic average as an usigned 60.18-decimal fixed-point number.
    function avg(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        // The operations can never overflow.
        unchecked {
            // The last operand checks if both x and y are odd and if that is the case, we add 1 to the result. We need
            // to do this because if both numbers are odd, the 0.5 remainder gets truncated twice.
            uint256 rValue = (x.value >> 1) +
                (y.value >> 1) +
                (x.value & y.value & 1);
            result = PRBMath.UD60x18({value: rValue});
        }
    }

    /// @notice Yields the least unsigned 60.18 decimal fixed-point number greater than or equal to x.
    ///
    /// @dev Optimised for fractional value inputs, because for every whole value there are (1e18 - 1) fractional counterparts.
    /// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
    ///
    /// Requirements:
    /// - x must be less than or equal to MAX_WHOLE_UD60x18.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number to ceil.
    /// @param result The least integer greater than or equal to x, as an unsigned 60.18-decimal fixed-point number.
    function ceil(PRBMath.UD60x18 memory x)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        uint256 xValue = x.value;
        require(xValue <= MAX_WHOLE_UD60x18);

        uint256 rValue;
        assembly {
            // Equivalent to "x % SCALE" but faster.
            let remainder := mod(xValue, SCALE)

            // Equivalent to "SCALE - remainder" but faster.
            let delta := sub(SCALE, remainder)

            // Equivalent to "x + delta * (remainder > 0 ? 1 : 0)" but faster.
            rValue := add(xValue, mul(delta, gt(remainder, 0)))
        }
        result = PRBMath.UD60x18({value: rValue});
    }

    /// @notice Divides two unsigned 60.18-decimal fixed-point numbers, returning a new unsigned 60.18-decimal fixed-point number.
    ///
    /// @dev Uses mulDiv to enable overflow-safe multiplication and division.
    ///
    /// Requirements:
    /// - y cannot be zero.
    ///
    /// @param x The numerator as an unsigned 60.18-decimal fixed-point number.
    /// @param y The denominator as an unsigned 60.18-decimal fixed-point number.
    /// @param result The quotient as an unsigned 60.18-decimal fixed-point number.
    function div(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        result = PRBMath.UD60x18({
            value: PRBMath.mulDiv(x.value, SCALE, y.value)
        });
    }

    /// @notice Returns Euler's number as an unsigned 60.18-decimal fixed-point number.
    /// @dev See https://en.wikipedia.org/wiki/E_(mathematical_constant).
    function e() internal pure returns (PRBMath.UD60x18 memory result) {
        result = PRBMath.UD60x18({value: 2718281828459045235});
    }

    /// @notice Calculates the natural exponent of x.
    ///
    /// @dev Based on the insight that e^x = 2^(x * log2(e)).
    ///
    /// Requirements:
    /// - All from "log2".
    /// - x must be less than 88.722839111672999628.
    ///
    /// @param x The exponent as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function exp(PRBMath.UD60x18 memory x)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        // Without this check, the value passed to "exp2" would be greater than 128e18.
        require(x.value < 88722839111672999628);

        // Do the fixed-point multiplication inline to save gas.
        unchecked {
            uint256 doubleScaleProduct = x.value * LOG2_E;
            PRBMath.UD60x18 memory exponent = PRBMath.UD60x18({
                value: (doubleScaleProduct + HALF_SCALE) / SCALE
            });
            result = exp2(exponent);
        }
    }

    /// @notice Calculates the binary exponent of x using the binary fraction method.
    ///
    /// @dev See https://ethereum.stackexchange.com/q/79903/24693.
    ///
    /// Requirements:
    /// - x must be 128e18 or less.
    /// - The result must fit within MAX_UD60x18.
    ///
    /// @param x The exponent as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function exp2(PRBMath.UD60x18 memory x)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        // 2**128 doesn't fit within the 128.128-bit format used internally in this function.
        require(x.value < 128e18);

        unchecked {
            // Convert x to the 128.128-bit fixed-point format.
            uint256 x128x128 = (x.value << 128) / SCALE;

            // Pass x to the PRBMath.exp2 function, which uses the 128.128-bit fixed-point number representation.
            result = PRBMath.UD60x18({value: PRBMath.exp2(x128x128)});
        }
    }

    /// @notice Yields the greatest unsigned 60.18 decimal fixed-point number less than or equal to x.
    /// @dev Optimised for fractional value inputs, because for every whole value there are (1e18 - 1) fractional counterparts.
    /// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
    /// @param x The unsigned 60.18-decimal fixed-point number to floor.
    /// @param result The greatest integer less than or equal to x, as an unsigned 60.18-decimal fixed-point number.
    function floor(PRBMath.UD60x18 memory x)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        uint256 xValue = x.value;
        uint256 rValue;
        assembly {
            // Equivalent to "x % SCALE" but faster.
            let remainder := mod(xValue, SCALE)

            // Equivalent to "x - remainder * (remainder > 0 ? 1 : 0)" but faster.
            rValue := sub(xValue, mul(remainder, gt(remainder, 0)))
        }
        result = PRBMath.UD60x18({value: rValue});
    }

    /// @notice Yields the excess beyond the floor of x.
    /// @dev Based on the odd function definition https://en.wikipedia.org/wiki/Fractional_part.
    /// @param x The unsigned 60.18-decimal fixed-point number to get the fractional part of.
    /// @param result The fractional part of x as an unsigned 60.18-decimal fixed-point number.
    function frac(PRBMath.UD60x18 memory x)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        uint256 xValue = x.value;
        uint256 rValue;
        assembly {
            rValue := mod(xValue, SCALE)
        }
        result = PRBMath.UD60x18({value: rValue});
    }

    /// @notice Converts a number from basic integer form to unsigned 60.18-decimal fixed-point representation.
    ///
    /// @dev Requirements:
    /// - x must be less than or equal to MAX_UD60x18 divided by SCALE.
    ///
    /// @param x The basic integer to convert.
    /// @param result The same number in unsigned 60.18-decimal fixed-point representation.
    function fromUint(uint256 x)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        unchecked {
            require(x <= MAX_UD60x18 / SCALE);
            result = PRBMath.UD60x18({value: x * SCALE});
        }
    }

    /// @notice Calculates geometric mean of x and y, i.e. sqrt(x * y), rounding down.
    ///
    /// @dev Requirements:
    /// - x * y must fit within MAX_UD60x18, lest it overflows.
    ///
    /// @param x The first operand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The second operand as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function gm(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        if (x.value == 0) {
            return PRBMath.UD60x18({value: 0});
        }

        unchecked {
            // Checking for overflow this way is faster than letting Solidity do it.
            uint256 xy = x.value * y.value;
            require(xy / x.value == y.value);

            // We don't need to multiply by the SCALE here because the x*y product had already picked up a factor of SCALE
            // during multiplication. See the comments within the "sqrt" function.
            result = PRBMath.UD60x18({value: PRBMath.sqrt(xy)});
        }
    }

    /// @notice Calculates 1 / x, rounding towards zero.
    ///
    /// @dev Requirements:
    /// - x cannot be zero.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the inverse.
    /// @return result The inverse as an unsigned 60.18-decimal fixed-point number.
    function inv(PRBMath.UD60x18 memory x)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        unchecked {
            // 1e36 is SCALE * SCALE.
            result = PRBMath.UD60x18({value: 1e36 / x.value});
        }
    }

    /// @notice Calculates the natural logarithm of x.
    ///
    /// @dev Based on the insight that ln(x) = log2(x) / log2(e).
    ///
    /// Requirements:
    /// - All from "log2".
    ///
    /// Caveats:
    /// - All from "log2".
    /// - This doesn't return exactly 1 for 2.718281828459045235, for that we would need more fine-grained precision.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the natural logarithm.
    /// @return result The natural logarithm as an unsigned 60.18-decimal fixed-point number.
    function ln(PRBMath.UD60x18 memory x)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        // Do the fixed-point multiplication inline to save gas. This is overflow-safe because the maximum value that log2(x)
        // can return is 196205294292027477728.
        unchecked {
            uint256 rValue = (log2(x).value * SCALE) / LOG2_E;
            result = PRBMath.UD60x18({value: rValue});
        }
    }

    /// @notice Calculates the common logarithm of x.
    ///
    /// @dev First checks if x is an exact power of ten and it stops if yes. If it's not, calculates the common
    /// logarithm based on the insight that log10(x) = log2(x) / log2(10).
    ///
    /// Requirements:
    /// - All from "log2".
    ///
    /// Caveats:
    /// - All from "log2".
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the common logarithm.
    /// @return result The common logarithm as an unsigned 60.18-decimal fixed-point number.
    function log10(PRBMath.UD60x18 memory x)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        uint256 xValue = x.value;
        require(xValue >= SCALE);

        // Note that the "mul" in this block is the assembly mul operation, not the "mul" function defined in this
        // contract.
        uint256 rValue;

        // prettier-ignore
        assembly {
            switch x
            case 1 { rValue := mul(SCALE, sub(0, 18)) }
            case 10 { rValue := mul(SCALE, sub(1, 18)) }
            case 100 { rValue := mul(SCALE, sub(2, 18)) }
            case 1000 { rValue := mul(SCALE, sub(3, 18)) }
            case 10000 { rValue := mul(SCALE, sub(4, 18)) }
            case 100000 { rValue := mul(SCALE, sub(5, 18)) }
            case 1000000 { rValue := mul(SCALE, sub(6, 18)) }
            case 10000000 { rValue := mul(SCALE, sub(7, 18)) }
            case 100000000 { rValue := mul(SCALE, sub(8, 18)) }
            case 1000000000 { rValue := mul(SCALE, sub(9, 18)) }
            case 10000000000 { rValue := mul(SCALE, sub(10, 18)) }
            case 100000000000 { rValue := mul(SCALE, sub(11, 18)) }
            case 1000000000000 { rValue := mul(SCALE, sub(12, 18)) }
            case 10000000000000 { rValue := mul(SCALE, sub(13, 18)) }
            case 100000000000000 { rValue := mul(SCALE, sub(14, 18)) }
            case 1000000000000000 { rValue := mul(SCALE, sub(15, 18)) }
            case 10000000000000000 { rValue := mul(SCALE, sub(16, 18)) }
            case 100000000000000000 { rValue := mul(SCALE, sub(17, 18)) }
            case 1000000000000000000 { rValue := 0 }
            case 10000000000000000000 { rValue := SCALE }
            case 100000000000000000000 { rValue := mul(SCALE, 2) }
            case 1000000000000000000000 { rValue := mul(SCALE, 3) }
            case 10000000000000000000000 { rValue := mul(SCALE, 4) }
            case 100000000000000000000000 { rValue := mul(SCALE, 5) }
            case 1000000000000000000000000 { rValue := mul(SCALE, 6) }
            case 10000000000000000000000000 { rValue := mul(SCALE, 7) }
            case 100000000000000000000000000 { rValue := mul(SCALE, 8) }
            case 1000000000000000000000000000 { rValue := mul(SCALE, 9) }
            case 10000000000000000000000000000 { rValue := mul(SCALE, 10) }
            case 100000000000000000000000000000 { rValue := mul(SCALE, 11) }
            case 1000000000000000000000000000000 { rValue := mul(SCALE, 12) }
            case 10000000000000000000000000000000 { rValue := mul(SCALE, 13) }
            case 100000000000000000000000000000000 { rValue := mul(SCALE, 14) }
            case 1000000000000000000000000000000000 { rValue := mul(SCALE, 15) }
            case 10000000000000000000000000000000000 { rValue := mul(SCALE, 16) }
            case 100000000000000000000000000000000000 { rValue := mul(SCALE, 17) }
            case 1000000000000000000000000000000000000 { rValue := mul(SCALE, 18) }
            case 10000000000000000000000000000000000000 { rValue := mul(SCALE, 19) }
            case 100000000000000000000000000000000000000 { rValue := mul(SCALE, 20) }
            case 1000000000000000000000000000000000000000 { rValue := mul(SCALE, 21) }
            case 10000000000000000000000000000000000000000 { rValue := mul(SCALE, 22) }
            case 100000000000000000000000000000000000000000 { rValue := mul(SCALE, 23) }
            case 1000000000000000000000000000000000000000000 { rValue := mul(SCALE, 24) }
            case 10000000000000000000000000000000000000000000 { rValue := mul(SCALE, 25) }
            case 100000000000000000000000000000000000000000000 { rValue := mul(SCALE, 26) }
            case 1000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 27) }
            case 10000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 28) }
            case 100000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 29) }
            case 1000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 30) }
            case 10000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 31) }
            case 100000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 32) }
            case 1000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 33) }
            case 10000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 34) }
            case 100000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 35) }
            case 1000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 36) }
            case 10000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 37) }
            case 100000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 38) }
            case 1000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 39) }
            case 10000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 40) }
            case 100000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 41) }
            case 1000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 42) }
            case 10000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 43) }
            case 100000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 44) }
            case 1000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 45) }
            case 10000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 46) }
            case 100000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 47) }
            case 1000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 48) }
            case 10000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 49) }
            case 100000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 50) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 51) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 52) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 53) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 54) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 55) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 56) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 57) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 58) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 59) }
            default {
                rValue := MAX_UD60x18
            }
        }

        if (rValue != MAX_UD60x18) {
            result = PRBMath.UD60x18({value: rValue});
        } else {
            // Do the fixed-point division inline to save gas. The denominator is log2(10).
            unchecked {
                rValue = (log2(x).value * SCALE) / 3321928094887362347;
                result = PRBMath.UD60x18({value: rValue});
            }
        }
    }

    /// @notice Calculates the binary logarithm of x.
    ///
    /// @dev Based on the iterative approximation algorithm.
    /// https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation
    ///
    /// Requirements:
    /// - x must be greater than or equal to SCALE, otherwise the result would be negative.
    ///
    /// Caveats:
    /// - The results are nor perfectly accurate to the last decimal, due to the lossy precision of the iterative approximation.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the binary logarithm.
    /// @return result The binary logarithm as an unsigned 60.18-decimal fixed-point number.
    function log2(PRBMath.UD60x18 memory x)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        require(x.value >= SCALE);
        unchecked {
            // Calculate the integer part of the logarithm and add it to the result and finally calculate y = x * 2^(-n).
            uint256 n = PRBMath.mostSignificantBit(x.value / SCALE);

            // The integer part of the logarithm as an unsigned 60.18-decimal fixed-point number. The operation can't overflow
            // because n is maximum 255 and SCALE is 1e18.
            uint256 rValue = n * SCALE;

            // This is y = x * 2^(-n).
            uint256 y = x.value >> n;

            // If y = 1, the fractional part is zero.
            if (y == SCALE) {
                return PRBMath.UD60x18({value: rValue});
            }

            // Calculate the fractional part via the iterative approximation.
            // The "delta >>= 1" part is equivalent to "delta /= 2", but shifting bits is faster.
            for (uint256 delta = HALF_SCALE; delta > 0; delta >>= 1) {
                y = (y * y) / SCALE;

                // Is y^2 > 2 and so in the range [2,4)?
                if (y >= 2 * SCALE) {
                    // Add the 2^(-m) factor to the logarithm.
                    rValue += delta;

                    // Corresponds to z/2 on Wikipedia.
                    y >>= 1;
                }
            }
            result = PRBMath.UD60x18({value: rValue});
        }
    }

    /// @notice Multiplies two unsigned 60.18-decimal fixed-point numbers together, returning a new unsigned 60.18-decimal
    /// fixed-point number.
    /// @dev See the documentation for the "PRBMath.mulDivFixedPoint" function.
    /// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function mul(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        result = PRBMath.UD60x18({
            value: PRBMath.mulDivFixedPoint(x.value, y.value)
        });
    }

    /// @notice Returns PI as an unsigned 60.18-decimal fixed-point number.
    function pi() internal pure returns (PRBMath.UD60x18 memory result) {
        result = PRBMath.UD60x18({value: 3141592653589793238});
    }

    /// @notice Raises x to the power of y.
    ///
    /// @dev Based on the insight that x^y = 2^(log2(x) * y).
    ///
    /// Requirements:
    /// - All from "exp2", "log2" and "mul".
    ///
    /// Caveats:
    /// - All from "exp2", "log2" and "mul".
    /// - Assumes 0^0 is 1.
    ///
    /// @param x Number to raise to given power y, as an unsigned 60.18-decimal fixed-point number.
    /// @param y Exponent to raise x to, as an unsigned 60.18-decimal fixed-point number.
    /// @return result x raised to power y, as an unsigned 60.18-decimal fixed-point number.
    function pow(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        if (x.value == 0) {
            return PRBMath.UD60x18({value: y.value == 0 ? SCALE : uint256(0)});
        } else {
            result = exp2(mul(log2(x), y));
        }
    }

    /// @notice Raises x (unsigned 60.18-decimal fixed-point number) to the power of y (basic unsigned integer) using the
    /// famous algorithm "exponentiation by squaring".
    ///
    /// @dev See https://en.wikipedia.org/wiki/Exponentiation_by_squaring
    ///
    /// Requirements:
    /// - The result must fit within MAX_UD60x18.
    ///
    /// Caveats:
    /// - All from "mul".
    /// - Assumes 0^0 is 1.
    ///
    /// @param x The base as an unsigned 60.18-decimal fixed-point number.
    /// @param y The exponent as an uint256.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function powu(PRBMath.UD60x18 memory x, uint256 y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        // Calculate the first iteration of the loop in advance.
        uint256 xValue = x.value;
        uint256 rValue = y & 1 > 0 ? xValue : SCALE;

        // Equivalent to "for(y /= 2; y > 0; y /= 2)" but faster.
        for (y >>= 1; y > 0; y >>= 1) {
            xValue = PRBMath.mulDivFixedPoint(xValue, xValue);

            // Equivalent to "y % 2 == 1" but faster.
            if (y & 1 > 0) {
                rValue = PRBMath.mulDivFixedPoint(rValue, xValue);
            }
        }
        result = PRBMath.UD60x18({value: rValue});
    }

    /// @notice Returns 1 as an unsigned 60.18-decimal fixed-point number.
    function scale() internal pure returns (PRBMath.UD60x18 memory result) {
        result = PRBMath.UD60x18({value: SCALE});
    }

    /// @notice Calculates the square root of x, rounding down.
    /// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    ///
    /// Requirements:
    /// - x must be less than MAX_UD60x18 / SCALE.
    ///
    /// Caveats:
    /// - The maximum fixed-point number permitted is 115792089237316195423570985008687907853269.984665640564039458.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the square root.
    /// @return result The result as an unsigned 60.18-decimal fixed-point .
    function sqrt(PRBMath.UD60x18 memory x)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        require(
            x.value <
                115792089237316195423570985008687907853269984665640564039458
        );
        unchecked {
            // Multiply x by the SCALE to account for the factor of SCALE that is picked up when multiplying two unsigned
            // 60.18-decimal fixed-point numbers together (in this case, those two numbers are both the square root).
            result = PRBMath.UD60x18({value: PRBMath.sqrt(x.value * SCALE)});
        }
    }

    /// @notice Subtracts one unsigned 60.18-decimal fixed-point number from another one, returning a new unsigned 60.18-decimal
    /// fixed-point number.
    /// @param x The unsigned 60.18-decimal fixed-point number to subtract from.
    /// @param y The unsigned 60.18-decimal fixed-point number to subtract.
    /// @param result The result as an unsigned 60.18 decimal fixed-point number.
    function sub(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        unchecked {
            require(x.value >= y.value);
            result = PRBMath.UD60x18({value: x.value - y.value});
        }
    }

    /// @notice Converts a unsigned 60.18-decimal fixed-point number to basic integer form, rounding down in the process.
    /// @param x The unsigned 60.18-decimal fixed-point number to convert.
    /// @return result The same number in basic integer form.
    function toUint(PRBMath.UD60x18 memory x)
        internal
        pure
        returns (uint256 result)
    {
        unchecked {
            result = x.value / SCALE;
        }
    }
}

// Part: EIP712

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// Part: ERC20Permit

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

// File: LearningCurve.sol

/**
 * @title  LearningCurve
 * @notice A simple constant product curve that mints LEARN tokens whenever
 *         anyone sends it DAI, or burns LEARN tokens and returns DAI.
 */
contract LearningCurve is ERC20Permit {
    using SafeERC20 for IERC20;

    // the constant product used in the curve
    uint256 public constant k = 10000;
    IERC20 public reserve;
    uint256 public reserveBalance;
    bool initialised;

    event LearnMinted(
        address indexed learner,
        uint256 amountMinted,
        uint256 daiDeposited
    );
    event LearnBurned(
        address indexed learner,
        uint256 amountBurned,
        uint256 daiReturned,
        uint256 e
    );

    constructor(address _reserve) ERC20Permit('Learning Curve') ERC20("Learning Curve", "LEARN") {
        reserve = IERC20(_reserve);
    }

    /**
     * @notice initialise the contract, mainly for maths purposes, requires the transfer of 1 DAI.
     * @dev    only callable once
     */
    function initialise() external {
        require(!initialised, "initialised");
        initialised = true;
        reserve.safeTransferFrom(msg.sender, address(this), 1e18);
        reserveBalance += 1e18;
        _mint(address(this), 10001e18);
    }

    /**
     * @notice handles LEARN mint with an approval for DAI
     */
    function permitAndMint(uint256 _amount, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) external {
        DaiPermit(address(reserve)).permit(msg.sender, address(this), nonce, expiry, true, v, r, s);
        mint(_amount);
    }
    /**
     * @notice This method allows anyone to mint LEARN tokens dependent on the
     *         amount of DAI they send.
     *
     *         The amount minted depends on the amount of collateral already locked in
     *         the curve. The more DAI is locked, the less LEARN gets minted, ensuring
     *         that the price of LEARN increases linearly.
     *
     *         Please see: https://docs.google.com/spreadsheets/d/1hjWFGPC_B9D7b6iI00DTVVLrqRFv3G5zFNiCBS7y_V8/edit?usp=sharing
     * @param  _wad amount of Dai to send to the contract
     */
    function mint(uint256 _wad) public {
        require(initialised, "!initialised");
        reserve.safeTransferFrom(msg.sender, address(this), _wad);
        uint256 ln = doLn((((reserveBalance + _wad) * 1e18)) / reserveBalance);
        uint256 learnMagic = k * ln;
        reserveBalance += _wad;
        _mint(msg.sender, learnMagic);
        emit LearnMinted(msg.sender, learnMagic, _wad);
    }

    /**
     * @notice Same as normal mint, except that an address is passed in which the minted
     *         LEARN is sent to. Necessary to allow for mints directly from a Course, where
     *         we want to learner to receive LEARN, not the course contract.
     *
     *         Can be used to send DAI from one address and have LEARN returned to another.
     * @param  learner address of the learner to mint LEARN to
     * @param  _wad    amount of DAI being sent in.
     */
    function mintForAddress(address learner, uint256 _wad) public {
        require(initialised, "!initialised");
        reserve.safeTransferFrom(msg.sender, address(this), _wad);
        uint256 ln = doLn((((reserveBalance + _wad) * 1e18)) / reserveBalance);
        uint256 learnMagic = k * ln;
        reserveBalance += _wad;
        _mint(learner, learnMagic);
        emit LearnMinted(learner, learnMagic, _wad);
    }

    /**
     * @notice used to burn LEARN and return DAI to the sender.
     * @param  _burnAmount amount of LEARN to burn
     */
    function burn(uint256 _burnAmount) public {
        require(initialised, "!initialised");
        uint256 e = e_calc(_burnAmount);
        uint256 learnMagic = reserveBalance - (reserveBalance * 1e18) / e;
        _burn(msg.sender, _burnAmount);
        reserveBalance -= learnMagic;
        reserve.safeTransfer(msg.sender, learnMagic);
        emit LearnBurned(msg.sender, _burnAmount, learnMagic, e);
    }

    /**
     * @notice Calculates the natural exponent of the inputted value
     * @param  x the number to be used in the natural log calc
     */
    function e_calc(uint256 x) internal pure returns (uint256 result) {
        PRBMath.UD60x18 memory xud = PRBMath.UD60x18({value: x / k});
        result = PRBMathUD60x18.exp(xud).value;
    }

    /**
     * @notice Calculates the natural logarithm of x.
     * @param  x      the number to be used in the natural log calc
     * @return result the natural log of the inputted value
     */
    function doLn(uint256 x) internal pure returns (uint256 result) {
        PRBMath.UD60x18 memory xud = PRBMath.UD60x18({value: x});
        result = PRBMathUD60x18.ln(xud).value;
    }

    /**
     * @notice calculates the amount of reserve received for a burn amount
     * @param  _burnAmount   the amount of LEARN to burn
     * @return learnMagic    the dai receivable for a certain amount of burnt LEARN
     */
    function getPredictedBurn(uint256 _burnAmount)
        external
        view
        returns (uint256 learnMagic)
    {
        uint256 e = e_calc(_burnAmount);
        learnMagic = reserveBalance - (reserveBalance * 1e18) / e;
    }

    /**
     * @notice calculates the amount of LEARN to mint given the amount of DAI requested.
     * @param  reserveAmount the amount of DAI to lock
     * @return learnMagic    the LEARN mintable for a certain amount of dai
     */
    function getMintableForReserveAmount(uint256 reserveAmount)
        external
        view
        returns (uint256 learnMagic)
    {
        uint256 ln = doLn(
            (((reserveBalance + reserveAmount) * 1e18)) / reserveBalance
        );
        learnMagic = k * ln;
    }
}