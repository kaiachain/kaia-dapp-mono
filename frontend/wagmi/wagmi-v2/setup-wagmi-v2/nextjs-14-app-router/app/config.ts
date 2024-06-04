import { 
  createConfig, 
  http, 
  cookieStorage, 
  createStorage 
} from 'wagmi'
import { klaytn, klaytnBaobab } from 'wagmi/chains'

export const config = createConfig({
  chains: [klaytn, klaytnBaobab],
  ssr: true,
  storage: createStorage({  
    storage: cookieStorage, 
  }),  
  transports: {
    [klaytn.id]: http("https://rpc.ankr.com/klaytn"), // you can replace the http() with any other RPC URL you like
    [klaytnBaobab.id]: http("https://rpc.ankr.com/klaytn_testnet") // you can replace the http() with any other RPC URL you like
  },
})