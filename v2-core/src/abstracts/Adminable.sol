// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IAdminable } from "../interfaces/IAdminable.sol";
import { Errors } from "../libraries/Errors.sol";

/// @title Adminable
/// @notice See the documentation in {IAdminable}.
abstract contract Adminable is IAdminable {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IAdminable
    address public override admin;
    address public pendingAdmin;

    /*//////////////////////////////////////////////////////////////////////////
                                      MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Reverts if called by any account other than the admin.
    modifier onlyAdmin() {
        if (admin != msg.sender) {
            revert Errors.CallerNotAdmin({ admin: admin, caller: msg.sender });
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Propose a new admin.
    /// @param newAdmin The address of the proposed new admin.
    function proposeAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "New admin address cannot be zero");
        pendingAdmin = newAdmin;
        emit IAdminable.ProposeAdmin({ oldAdmin: admin, proposedAdmin: newAdmin });
    }

    /// @notice Accept the admin role.
    function acceptAdmin() public {
        require(msg.sender == pendingAdmin, "Only proposed admin can accept");
        admin = pendingAdmin;
        pendingAdmin = address(0);
        emit IAdminable.TransferAdmin({ oldAdmin: admin, newAdmin: msg.sender });
    }
}
