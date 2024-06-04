// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MinimalProxyFactory {
    address[] public proxies;

    event Response(bool success, bytes data);

    function deployClone(
        address _implementationContract
    ) external returns (address) {
        // convert the address to 20 bytes
        bytes20 implementationContractInBytes = bytes20(
            _implementationContract
        );
        //address to assign a cloned proxy
        address proxy;

        // as stated earlier, the minimal proxy has this bytecode
        // <3d602d80600a3d3981f3363d3d373d3d3d363d73><address of implementation contract><5af43d82803e903d91602b57fd5bf3>

        // <3d602d80600a3d3981f3> == creation code which copies runtime code into memory and deploys it

        // <363d3d373d3d3d363d73> <address of implementation contract> <5af43d82803e903d91602b57fd5bf3> == runtime code that makes a delegatecall to the implentation contract

        assembly {
            /*
           reads the 32 bytes of memory starting at the pointer stored in 0x40
           In solidity, the 0x40 slot in memory is special: it contains the "free memory pointer"
           which points to the end of the currently allocated memory.
           */
            let clone := mload(0x40)
            // store 32 bytes to memory starting at "clone"
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )

            /*
             |              20 bytes                |
           0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
                                                     ^
                                                     pointer
           */
            // store 32 bytes to memory starting at "clone" + 20 bytes
            // 0x14 = 20
            mstore(add(clone, 0x14), implementationContractInBytes)

            /*
             |               20 bytes               |                 20 bytes              |
           0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe
                                                                                             ^
                                                                                             pointer
           */
            // store 32 bytes to memory starting at "clone" + 40 bytes
            // 0x28 = 40
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )

            /*
           |                 20 bytes                  |          20 bytes          |           15 bytes          |
           0x3d602d80600a3d3981f3363d3d373d3d3d363d73b<implementationContractInBytes>5af43d82803e903d91602b57fd5bf3 == 45 bytes in total
           */

            // create a new contract
            // send 0 Ether
            // code starts at the pointer stored in "clone"
            // code size == 0x37 (55 bytes)
            proxy := create(0, clone, 0x37)
        }

        // Call initialization
        (bool success, bytes memory data) = proxy.call(
            abi.encodeWithSignature("setValue(uint256)", 123)
        );

        emit Response(success, data);
        proxies.push(proxy);
        return proxy;
    }
}
