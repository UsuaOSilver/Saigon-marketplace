// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.12;


error PlatformFeeInfoUpdated(address _platformFeeRecipient, uint16 _platformFeeBps);
/*
* @title Platform Fee
* @notice Thirdweb's `PlatformFee` is a contract extension to be used with any base contract. It exposes functios for setting and reading
          the recipient of platform fee and the platform fee basis points, and letting the inheriting contract perform conditional logic
          that uses information about platform fees, if desired.
*/

abstract contract PlatformFee {
    
    /// ==========================
    /// ==== Global Variables ====
    /// ==========================
    
    /// @dev The address that recieves all platform fees from all sales.
    address private platformFeeRecipient;
    
    /// @dev The % of primary sales collected as platform fees.
    uint16 private platformFeeBps;
    
    
    /// ==========================
    /// ==== Functions ====
    /// ==========================
    
    /// @dev Returns the platform fee recipient and bps.
    function getPlatformFeeInfo() public view returns (address, uint16) {
        return (platformFeeRecipient, uint16(platformFeeBps));
    }
    
    /** 
     * @notice      Updates the platform fee recipient and bps.
     * @dev         Caller should be authorized to set platform fee info.
     *              See {_canSetPlatformFeeInfo}.
     *              Emits {PlatformFeeInfoUpdated Event}; See {_setupPlatformFeeInfo}.
     *
     * @param _platformFeeRecipient     Address to be set as new platformFeeRecipient.
     * @param _platformFeeBps           updated platformFeeBps.
     */
    function setPlatformFeeInfo(address _platformFeeRecipient, uint256 _platformFeeBps) external {
        if (!_canSetPlatformFeeInfo()) {
            revert("Not authorized");
        }
        
        _setupPlatformFeeInfo(_platformFeeRecipient, _platformFeeBps);
    }
    
    /// @dev Let's a contract admin update the platform fee recipient and pbs
    function _setupPlatformFeeInfo(address _platformFeeRecipient, uint256 _platformFeeBps) internal {
        if (_platformFeeBps > 10_000) {
            revert("Exceed max bps");
        }
        
        platformFeeBps = uint16(_platformFeeBps);
        platformFeeRecipient = _platformFeeRecipient;
        
        emit PlatformFeeInfoUpdated(_platformFeeRecipient, _platformFeeBps);
    }
    
    /// @dev Returns whether platform fee info can be set in the given execution context.
    function _canSetPlatformFeeInfo() internal view virtual returns (bool);
}