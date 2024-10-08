import type { Request, Response, NextFunction } from "express";
import { createWallet } from "./handlers/createWallet";
import { signWithEthers } from "./handlers/signWithEthers";
import { signWithViem } from "./handlers/signWithViem";
import { signWithCosmJS } from "./handlers/signWithCosmJS";
import { signWithSolanaWeb3 } from "./handlers/signWithSolanaWeb3";
import { signWithAlchemy } from "./handlers/signWithAlchemy";
import { signWithCapsulePreGen } from "./handlers/signWithCapsuleClient";
import { signWithCapsuleSession } from "./handlers/signWithCapsuleSession";

export interface Route {
  path: string;
  method: "POST";
  handler: (req: Request, res: Response, next: NextFunction) => Promise<Response<any, Record<string, any>> | void>;
}

export const routes: Route[] = [
  { path: "/wallets/create", method: "POST", handler: createWallet },
  { path: "/wallets/sign/capsulePreGen", method: "POST", handler: signWithCapsulePreGen },
  { path: "/wallets/sign/capsuleSession", method: "POST", handler: signWithCapsuleSession },
  { path: "/wallets/sign/ethers", method: "POST", handler: signWithEthers },
  { path: "/wallets/sign/viem", method: "POST", handler: signWithViem },
  { path: "/wallets/sign/cosmjs", method: "POST", handler: signWithCosmJS },
  { path: "/wallets/sign/solana-web3", method: "POST", handler: signWithSolanaWeb3 },
  { path: "/wallets/sign/alchemy", method: "POST", handler: signWithAlchemy },
];