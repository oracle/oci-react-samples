import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './components/App';
import {BrowserRouter, Route, Routes} from "react-router-dom";

ReactDOM.render(
  <BrowserRouter>
      <Routes>
          <Route path="/*" element={<App/>} />
      </Routes>
  </BrowserRouter>,
  document.getElementById('root')
);
