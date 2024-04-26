import { Outlet, Link } from "react-router-dom";
import Nav from "./nav";
import Footer from "./footer";
// import { ConnectButton } from "@rainbow-me/rainbowkit";

function Body() {
  return (
    <>
      <Nav />
      <div className="Body">
        <div className="Body__Title">
          Make the most of your{" "}
          <span className="Body__Crypto">cryptocurrency</span>
        </div>
        <div className="Body__description">
          Summer is making credit more accessible, transparent, and programmable
          by bringing debt infrastructure on-chain.
        </div>
        <Link to="BorrowLend" className="Body__LaunchApp">
          Go to app
        </Link>
      </div>
      <Outlet />
      <Footer />
    </>
  );
}

export default Body;
