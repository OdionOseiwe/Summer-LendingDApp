import { Outlet, Link } from "react-router-dom";
import { useState } from "react";
import { ConnectButton } from "@web3uikit/web3";
import { useMoralis } from "react-moralis";

function Nav() {
  const [menuOpen, setMenuOpen] = useState(false);

  const { isWeb3Enabled, chainId: chainIdHex } = useMoralis();
  const chainId = parseInt(chainIdHex).toString();

  const supportedChains = ["97"];


  return (
    <>
      <div className="Connect_btn">
        <ConnectButton/>
        {
          supportedChains.includes(chainId) ? (
              <div></div>
          ) : (
              <p>Switch to BNB testnet</p>
          )}
      </div>
      <div className="Header">
        <div
          className="menu"
          onClick={() => {
            setMenuOpen(!menuOpen);
          }}
        >
          <span></span>
          <span></span>
          <span></span>
        </div>
        <nav className={menuOpen ? "open" : " "}>
          <Link to="/" className="nav__logo">
            Summer
          </Link>
          <Link to="/" className="nav__docs">
            Docs
          </Link>
          <Link to="/" className="nav__Community">
            Community
          </Link>
        </nav>
        <Outlet />
      </div>
    </>
  );
}

export default Nav;
