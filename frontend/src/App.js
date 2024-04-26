import "./App.css";
import Home from "./Components/Home";
import Community from "./Components/Community";
import Docs from "./Components/Docs";
import BorrowLend from "./Components/BorrowLend";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { ToastProvider } from "react-toast-notifications";

function App() {
  const toastOptions = {
    style: {
      color:'',
    },
  };

  return (
    <>
      <ToastProvider toastOptions={toastOptions}>
        <BrowserRouter>
          <Routes>
            <Route path="/">
              <Route index element={<Home />} />
              <Route path="community" element={<Community />} />
              <Route path="docs" element={<Docs />} />
              <Route path="borrowLend" element={<BorrowLend />} />
            </Route>
          </Routes>
        </BrowserRouter>
      </ToastProvider>
    </>
  );
}

export default App;
