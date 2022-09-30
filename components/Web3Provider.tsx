import React from 'react';
import { useTheme } from 'next-themes'
import { createClient, WagmiConfig } from 'wagmi'
import { ConnectKitProvider, getDefaultClient } from 'connectkit'

const infuraId = process.env.INFURA_IPFS_PROJECT_ID;

const client = createClient(
	getDefaultClient({
		appName: 'SAIGON_MARKETPLACE',
		autoConnect: true,
		infuraId,
	})
)

const Web3Provider = ({ children }) => {
	const { resolvedTheme } = useTheme()

	return (
		<WagmiConfig client={client}>
			<ConnectKitProvider mode={resolvedTheme as 'light' | 'dark'}>{children}</ConnectKitProvider>
		</WagmiConfig>
	)
}

export default Web3Provider