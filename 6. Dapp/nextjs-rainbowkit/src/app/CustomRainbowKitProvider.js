'use client';
import '@rainbow-me/rainbowkit/styles.css';
import {
  getDefaultConfig,
  RainbowKitProvider,
} from '@rainbow-me/rainbowkit';
import { WagmiProvider } from 'wagmi';
import {
  sepolia,
} from 'wagmi/chains';
import {
  QueryClientProvider,
  QueryClient,
} from "@tanstack/react-query";

const config = getDefaultConfig({
  appName: 'My RainbowKit App',
  projectId: process.env.NEXT_PUBLIC_PROJECT_ID,
  chains: [sepolia],
  ssr: true, // If your dApp uses server side rendering (SSR)
});

const queryClient = new QueryClient();

const CustomRainbowKitProvider = ({children}) => {
    return (
        <WagmiProvider config={config}>
        <QueryClientProvider client={queryClient}>
            <RainbowKitProvider>
                {children}
            </RainbowKitProvider>
        </QueryClientProvider>
        </WagmiProvider>
    );
}
export default CustomRainbowKitProvider