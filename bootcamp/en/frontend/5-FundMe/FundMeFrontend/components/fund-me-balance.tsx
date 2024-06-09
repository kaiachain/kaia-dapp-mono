'use client'
import { useBalance } from 'wagmi'
import { Skeleton } from "@/components/ui/skeleton"
import { formatEther } from 'viem'
import { Button } from "@/components/ui/button"
import { RefreshCcw } from "lucide-react"


export default function FundMeBalanceCard() {
  const contractAddress = "0x1dB58359534600b08Fe7061608920f1C47E7b0b0";
  const {data: result, isPending, refetch} = useBalance({
    address: contractAddress,
  });
  const balance = formatEther(result?.value ?? BigInt(0));

  return (
    <div className="flex flex-col gap-2 rounded-lg p-4 shadow-xl w-full lg:max-w-3xl">
      <div className="flex flex-row justify-between">
        <h1 className="text-2xl font-semibold">Contract Balance</h1>
        <Button variant="outline" size="icon" onClick={() => refetch()}>
          <RefreshCcw className="h-4 w-4" />
        </Button>
      </div>
      <p className="italic text-sm">Current balance in the Fund Me contract</p>
      {isPending ? <Skeleton className="w-[50px] h-[20px]" /> : <p className="text-xl font-mono flex flex-row items-center">{balance} KLAY</p>}
    </div>
  );
}