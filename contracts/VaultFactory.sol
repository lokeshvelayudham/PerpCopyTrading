// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.27;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {VaultProxy} from "./VaultProxy.sol";
import {VaultImplementation} from "./VaultImplementationV1.sol";

contract VaultFactory {

    address public governor;
    address public keeper;

    mapping (address => mapping(address => bytes32)) vaults;

    event CreateVault(address creator, bytes32 name, address vaultImplementation, address vaultProxy);
    event DeleteVault(address creator, address vaultProxy);

    modifier onlyGov {
        require(msg.sender == governor);
        _;
    }

    constructor() {
        governor = msg.sender;
    }


    function setGovernor(address newGovernor) public onlyGov {
        governor = newGovernor;
    }

    function setKeeper(address newKeeper) public onlyGov {
        keeper = newKeeper;
    }

    function withdrawETH(address recepient) public onlyGov{
        payable(recepient).transfer(address(this).balance);
    }

    function withdrawTokens(address token, address recepient, uint256 tokenAmount) public onlyGov{
       IERC20(token).transfer(recepient, tokenAmount);
    }


    function createVault(bytes32 name) public {

       VaultImplementation vaultImplementation = new VaultImplementation();
       VaultProxy vaultProxy = new VaultProxy(address(vaultImplementation));

       VaultImplementation(address(vaultProxy)).initialize(name);
       
       vaults[msg.sender][address(vaultProxy)] = name;

       emit CreateVault(msg.sender, name, address(vaultImplementation), address(vaultProxy));
    }

    function deleteVault(address vaultProxy) public {
       delete vaults[msg.sender][vaultProxy];

       emit DeleteVault(msg.sender, vaultProxy);
    }
}
