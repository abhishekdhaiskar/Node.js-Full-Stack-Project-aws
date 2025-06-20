
import React, { useEffect, useState } from 'react';

function App() {
  const [msg, setMsg] = useState("loading...");
  useEffect(() => {
    fetch('/api/hello')
      .then(r => r.json())
      .then(d => setMsg(d.message))
      .catch(() => setMsg("error"));
  }, []);
  return <div><h1>Message from backend:</h1><p>{msg}</p></div>;
}

export default App;
