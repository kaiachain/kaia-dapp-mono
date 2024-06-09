import { ConnectButton } from '@rainbow-me/rainbowkit';
import FundMeBalanceCard from '@/components/fund-me-balance';
import FundCard from '@/components/fund';
import MyFund from '@/components/my-fund';

export default function Home() {

  return (
    <div className="flex flex-col gap-8 items-center justify-center py-12 px-4 p-48:lg">
      <ConnectButton />
      <FundMeBalanceCard />
      <MyFund />
      <FundCard />
    </div>
  );
}
