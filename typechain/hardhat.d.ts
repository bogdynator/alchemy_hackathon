/* Autogenerated file. Do not edit manually. */

/* tslint:disable */

/* eslint-disable */
import { FactoryOptions, HardhatEthersHelpers as HardhatEthersHelpersBase } from "@nomiclabs/hardhat-ethers/types";
import { ethers } from "ethers";

import * as Contracts from ".";

declare module "hardhat/types/runtime" {
  interface HardhatEthersHelpers extends HardhatEthersHelpersBase {
    getContractFactory(
      name: "AccessControl",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.AccessControl__factory>;
    getContractFactory(
      name: "IAccessControl",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.IAccessControl__factory>;
    getContractFactory(
      name: "Ownable",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.Ownable__factory>;
    getContractFactory(
      name: "IVotes",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.IVotes__factory>;
    getContractFactory(
      name: "ERC20",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.ERC20__factory>;
    getContractFactory(
      name: "ERC20Permit",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.ERC20Permit__factory>;
    getContractFactory(
      name: "IERC20Permit",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.IERC20Permit__factory>;
    getContractFactory(
      name: "ERC20Votes",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.ERC20Votes__factory>;
    getContractFactory(
      name: "IERC20Metadata",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.IERC20Metadata__factory>;
    getContractFactory(
      name: "IERC20",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.IERC20__factory>;
    getContractFactory(
      name: "ERC165",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.ERC165__factory>;
    getContractFactory(
      name: "IERC165",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.IERC165__factory>;
    getContractFactory(
      name: "Token",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.Token__factory>;
    getContractFactory(
      name: "TokenVote",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.TokenVote__factory>;
    getContractFactory(
      name: "VotingSystem",
      signerOrOptions?: ethers.Signer | FactoryOptions,
    ): Promise<Contracts.VotingSystem__factory>;
    getContractFactory(name: "VTS", signerOrOptions?: ethers.Signer | FactoryOptions): Promise<Contracts.VTS__factory>;

    getContractAt(name: "AccessControl", address: string, signer?: ethers.Signer): Promise<Contracts.AccessControl>;
    getContractAt(name: "IAccessControl", address: string, signer?: ethers.Signer): Promise<Contracts.IAccessControl>;
    getContractAt(name: "Ownable", address: string, signer?: ethers.Signer): Promise<Contracts.Ownable>;
    getContractAt(name: "IVotes", address: string, signer?: ethers.Signer): Promise<Contracts.IVotes>;
    getContractAt(name: "ERC20", address: string, signer?: ethers.Signer): Promise<Contracts.ERC20>;
    getContractAt(name: "ERC20Permit", address: string, signer?: ethers.Signer): Promise<Contracts.ERC20Permit>;
    getContractAt(name: "IERC20Permit", address: string, signer?: ethers.Signer): Promise<Contracts.IERC20Permit>;
    getContractAt(name: "ERC20Votes", address: string, signer?: ethers.Signer): Promise<Contracts.ERC20Votes>;
    getContractAt(name: "IERC20Metadata", address: string, signer?: ethers.Signer): Promise<Contracts.IERC20Metadata>;
    getContractAt(name: "IERC20", address: string, signer?: ethers.Signer): Promise<Contracts.IERC20>;
    getContractAt(name: "ERC165", address: string, signer?: ethers.Signer): Promise<Contracts.ERC165>;
    getContractAt(name: "IERC165", address: string, signer?: ethers.Signer): Promise<Contracts.IERC165>;
    getContractAt(name: "Token", address: string, signer?: ethers.Signer): Promise<Contracts.Token>;
    getContractAt(name: "TokenVote", address: string, signer?: ethers.Signer): Promise<Contracts.TokenVote>;
    getContractAt(name: "VotingSystem", address: string, signer?: ethers.Signer): Promise<Contracts.VotingSystem>;
    getContractAt(name: "VTS", address: string, signer?: ethers.Signer): Promise<Contracts.VTS>;

    // default types
    getContractFactory(name: string, signerOrOptions?: ethers.Signer | FactoryOptions): Promise<ethers.ContractFactory>;
    getContractFactory(
      abi: any[],
      bytecode: ethers.utils.BytesLike,
      signer?: ethers.Signer,
    ): Promise<ethers.ContractFactory>;
    getContractAt(nameOrAbi: string | any[], address: string, signer?: ethers.Signer): Promise<ethers.Contract>;
  }
}
