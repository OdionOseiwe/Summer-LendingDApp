import { ConnectButton } from '@rainbow-me/rainbowkit';
function Nav() {
    return (    
    <div className='Header'>  
    <div className='Nav'>
      <div className='nav__logo'>Summer</div>
      <div className='nav__docs'>Docs</div>
      <div className='nav__Community'>Community</div>
    </div>

    <div className='Connect_btn'>
      <ConnectButton  />
    </div>
  </div> );
}

export default Nav;