import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import App from "./App";
import "@rainbow-me/rainbowkit/styles.css";
import { WagmiProvider } from "wagmi";
import { MoralisProvider } from "react-moralis";
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";
import { http, createConfig } from "wagmi";
import { bscTestnet } from "wagmi/chains";

const config = createConfig({
  chains: [bscTestnet],
  transports: {
    [bscTestnet.id]: http(),
  },
});

const queryClient = new QueryClient();

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <MoralisProvider initializeOnMount={false}>
          <App />
        </MoralisProvider>
      </QueryClientProvider>
    </WagmiProvider>
  </React.StrictMode>
);
