import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Outlet, Link } from "react-router-dom";

function Nav() {
    return (    
    <div className='Header'>  
    <div className='Nav'>
      <Link  to="/" className='nav__logo'>Summer</Link>
      <Link  to="/docs" className='nav__docs'>Docs</Link>
      <Link  to="/community" className='nav__Community'>Community</Link>
    </div>

    <div className='Connect_btn'>
      <ConnectButton  />
    </div>
    <Outlet/>
    </div> 
  );
}

export default Nav;