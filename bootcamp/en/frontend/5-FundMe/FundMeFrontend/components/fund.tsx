'use client'

import { zodResolver } from "@hookform/resolvers/zod"
import { useForm } from "react-hook-form"
import { z } from "zod"
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"
import { useToast } from "@/components/ui/use-toast"
import { useWaitForTransactionReceipt, useWriteContract } from 'wagmi'
import { useReadContract } from 'wagmi'
import { abi } from './abi'
import { parseEther } from 'viem'
import { formatEther } from 'viem'
import { serialize } from 'wagmi' 
import { Skeleton } from "@/components/ui/skeleton"
import { Badge } from "@/components/ui/badge"
import { Loader2, Check } from "lucide-react"


const formSchema = z.object({
  amount: z.coerce
            .number({
              required_error: "Amount is required",
              invalid_type_error: "Amount must be a number",
            })
            .positive({ message: "Amount must be positive" }),
})

export default function FundCard() {
  const { toast } = useToast()
  const { data: hash, isPending, writeContract } = useWriteContract() 
  const { data: minimumAmount } = useReadContract({
    abi,
    address: '0x1dB58359534600b08Fe7061608920f1C47E7b0b0',
    functionName: 'MINIMUM_USD',
  })
  const MINIMUM_USD = formatEther(minimumAmount ?? BigInt(0))
  // 1. Define your form.
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
  })
  // 2. Define a submit handler.
  function onSubmit(values: z.infer<typeof formSchema>) {
    writeContract({ 
      abi, 
      address: '0x1dB58359534600b08Fe7061608920f1C47E7b0b0', 
      functionName: 'fund',
      value: parseEther(values.amount.toString()), 
    })
  }

  function truncateAddress(address: string) {
    return `${address.slice(0, 6)}...${address.slice(-6)}`
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = 
    useWaitForTransactionReceipt({ 
      hash, 
    }) 

  return (
    <Card className="w-full border-0 shadow-lg lg:max-w-3xl">
      <CardHeader>
        <CardTitle>Fund contract</CardTitle>
        <CardDescription>Contribute to the contract and fund future development</CardDescription>
      </CardHeader>
      <CardContent>
        <Form {...form} >
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
            <FormField
              control={form.control}
              name="amount"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Amount</FormLabel>
                  <FormControl>
                    <Input type="number" placeholder="Enter an amount in KLAY" {...field} value={field.value ?? ''} />
                  </FormControl>
                  <FormDescription>
                    You will fund the contract with this amount. Minimum amount is {MINIMUM_USD ? MINIMUM_USD : "..."} USD.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
            {isPending ? (
              <Button disabled>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Please wait
              </Button>
              )
              : (
                <Button type="submit">
                  Fund
                </Button>
              )
            }
          </form>
        </Form>
      </CardContent>
      <CardFooter className="flex flex-col gap-2 items-start h-fit">
        <h3 className="scroll-m-20 text-lg font-semibold tracking-tight">Transaction status</h3>
        {hash ? 
          <div className="flex flex-row gap-2">
            Hash: 
            <a target="_blank" className="text-blue-500 underline" href={`https://baobab.klaytnfinder.io/tx/${hash}`}>{truncateAddress(hash)}</a>
          </div>
          :
          <>
            <div className="flex flex-row gap-2">
              Hash: no transaction hash until after submission
            </div>
            <Badge variant="outline">
              No transaction yet
            </Badge>
          </> 

        }
        {isConfirming && 
          <Badge variant="secondary">
            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            Waiting for confirmation...
          </Badge>
        } 
        {isConfirmed && 
          <Badge className="flex flex-row items-center bg-green-500 cursor-pointer">
            <Check className="mr-2 h-4 w-4" />
            Transaction confirmed!
          </Badge>
        } 
      </CardFooter>
    </Card>
  )
}