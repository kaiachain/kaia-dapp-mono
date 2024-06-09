"use client";

import { useReadContract } from "wagmi";
import { abi } from "./abi";
import { formatEther } from "viem";
import { Skeleton } from "@/components/ui/skeleton";
import { useAccount } from "wagmi";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { RefreshCcw } from "lucide-react";

export default function MyFund() {
  const account = useAccount();
  const {
    data: amountFunded,
    isPending,
    isFetched,
    isSuccess,
    refetch
  } = useReadContract({
    abi,
    address: "0x1dB58359534600b08Fe7061608920f1C47E7b0b0",
    functionName: "getAddressToAmountFunded",
    args: [account.address ?? "0x0"],
    query: {
      // if account is not connected, don't query
      enabled: !!account.address,
    },
  });
  return (
    <div className="flex flex-col gap-2 rounded-lg p-4 shadow-xl w-full lg:max-w-3xl">
      <div className="flex flex-row justify-between">
        <h1 className="text-2xl font-semibold">My funded amount</h1>
        <Button variant="outline" size="icon" onClick={() => refetch()}>
          <RefreshCcw className="h-4 w-4" />
        </Button>
      </div>
      <p className="italic text-sm">
        Total amount of KLAY that I have funded the contract
      </p>
      {isPending && isFetched ? (
        <Skeleton className="w-[50px] h-[20px]" />
      ) : isSuccess ? (
        <p className="text-xl font-mono flex flex-row items-center">
          {formatEther(amountFunded ?? BigInt(0))} KLAY
        </p>
      ) : (
        <Badge className="w-fit" variant="secondary">
          Connect to see your funded amount
        </Badge>
      )}
    </div>
  );
}
