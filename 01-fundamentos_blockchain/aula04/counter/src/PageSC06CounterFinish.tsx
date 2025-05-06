import { useRef, useState} from 'react';
import './App.css';

import { DefaultProvider, bsv, TestWallet } from "scrypt-ts";
import { getSpentOutput} from './mProviders';
import { sleep } from "./myUtils";

import { Counter } from "./contracts/counter";

let homepvtKey = "3c2ffdbb0a57c0cff0deacba15a92bf1d218dda9a9c7c668dd0640a6204b6394" 
let homenetwork = bsv.Networks.testnet

let Alice: TestWallet
let txlink2 = ""

function PageSC06CounterFinish() {

  const [deployedtxid, setdeptxid] = useState("");
  const [linkUrl, setLinkUrl] = useState("");
  const txid = useRef<any>(null);
  const txidPrvStt = useRef<any>(null);

  const interact = async (amount: any) => {
    setdeptxid("Wait!!!")
    let provider = new DefaultProvider({network: homenetwork});
    if(txid.current.value.length === 64 || txidPrvStt.current.value.length === 64)
    {
      let privateKey = bsv.PrivateKey.fromHex(homepvtKey, homenetwork) 
      Alice = new TestWallet(privateKey, provider)
      try {  
        const signer = Alice
        await signer.connect(provider)
        let tx = new bsv.Transaction
        if(txid.current.value.length === 64) {
            tx = await provider.getTransaction(txid.current.value)
        }
        else if(txidPrvStt.current.value.length === 64) {
            let currentStateTXID = txidPrvStt.current.value
            let stxos = await getSpentOutput(currentStateTXID, 0, homenetwork)
            while(stxos[0].inputIndex !== -1)
            {
              currentStateTXID = stxos[0].txId;
              await sleep(500);
              stxos = await getSpentOutput(currentStateTXID, 0, homenetwork)
              console.log("Input:", stxos[0].inputIndex)
            }
            tx = await provider.getTransaction(currentStateTXID)
        }
        console.log('Current State TXID: ', tx.id)
        const counter = Counter.fromTx(tx, 0)
        await counter.connect(signer)
  
        const { tx: callTx } = await counter.methods.finish()
        console.log( 'Counter: ', counter.count)
        console.log( 'TXID: ', callTx.id)
              
        if(homenetwork === bsv.Networks.mainnet ) {
          txlink2 = "https://whatsonchain.com/tx/" + callTx.id;
        } else if (homenetwork === bsv.Networks.testnet ) {
          txlink2 = "https://test.whatsonchain.com/tx/" + callTx.id;
        }
        setLinkUrl(txlink2);
        setdeptxid(callTx.id)
      } catch (e) {
        console.error('Finish fails', e)
        alert('Finish fails')
        setdeptxid("")
      }
    }
    else {
      alert('Wrong TXID Format!!!')
      setdeptxid("Try Again!!!")
    }
  };

  return (
    <div className="App">
        <header className="App-header">
        <h2 style={{ fontSize: '34px', paddingBottom: '5px', paddingTop: '5px'}}>
          <meta name="viewport" content="width=device-width, initial-scale=1.0"></meta>   
          On Chain Counter - Finish
        </h2>
        <div>
          <div style={{ textAlign: 'center' , paddingBottom: '20px' }}>
                <label style={{ fontSize: '14px', paddingBottom: '2px' }}
                  >Inform Current or Previous State TXID:  
                </label>     
          </div>
          <div style={{ textAlign: 'center', paddingBottom: '20px' }}>
                <label style={{ fontSize: '14px', paddingBottom: '5px' }}  
                > 
                    <input ref={txid} type="hex" name="PVTKEY1" min="1" placeholder="current state" />
                </label>     
          </div>
          <div style={{ textAlign: 'center', paddingBottom: '20px' }}>
                <label style={{ fontSize: '14px', paddingBottom: '5px' }}  
                > 
                    <input ref={txidPrvStt} type="hex" name="PVTKEY1" min="1" placeholder="pevious state (optional)" />
                </label>     
          </div>
          <div style={{ textAlign: 'center' }}>     
                <button className="insert" onClick={interact}
                    style={{ fontSize: '14px', paddingBottom: '2px', marginLeft: '0px'}}
                >Finish</button>
          </div>
        </div>
        {
          deployedtxid.length === 64?
          <div>
          <div className="label-container" style={{ fontSize: '12px', paddingBottom: '0px', paddingTop: '20px' }}>
            <p className="responsive-label" style={{ fontSize: '12px' }}>TXID: {deployedtxid} </p>
          </div>
          <div className="label-container" style={{ fontSize: '12px', paddingBottom: '20px', paddingTop: '0px' }}>
            <p className="responsive-label" style={{ fontSize: '12px' }}>TX link: {' '} 
                <a href={linkUrl} target="_blank" style={{ fontSize: '12px', color: "cyan"}}>
                {linkUrl}</a></p>
          </div>
        </div>
          :
          <div className="label-container" style={{ fontSize: '12px', paddingBottom: '20px', paddingTop: '20px' }}>
          <p className="responsive-label" style={{ fontSize: '12px' }}>{deployedtxid} </p>
        </div>
        }                  
      </header>
    </div>
  );
}

export default PageSC06CounterFinish;