/**
 * Copyright (c) 2024 Oracle and/or its affiliates.

 * The Universal Permissive License (UPL), Version 1.0

 * Subject to the condition set forth below, permission is hereby granted to any
 * person obtaining a copy of this software, associated documentation and/or data
 * (collectively the "Software"), free of charge and under any and all copyright
 * rights in the Software, and any and all patent rights owned or freely
 * licensable by each licensor hereunder covering either (i) the unmodified
 * Software as contributed to or provided by such licensor, or (ii) the Larger
 * Works (as defined below), to deal in both

 * (a) the Software, and
 * (b) any piece of software and/or hardware listed in the lrgrwrks.txt file if
 * one is included with the Software (each a "Larger Work" to which the Software
 * is contributed by such licensors),

 * without restriction, including without limitation the rights to copy, create
 * derivative works of, display, perform, and distribute the Software and make,
 * use, sell, offer for sale, import, export, have made, and have sold the
 * Software and the Larger Work(s), and to sublicense the foregoing rights on
 * either these or other terms.

 * This license is subject to the following condition:
 * The above copyright notice and either this complete permission notice or at
 * a minimum a reference to the UPL must be included in all copies or
 * substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.

 */

/*
 * This is the application main React component. We're using "function"
 * components in this application. No "class" components should be used for
 * consistency.
 * @author  jean.de.lavarene@oracle.com
 */
import React, {useEffect, useState} from 'react';
import NewItem from './NewItem';
import API_LIST from './API';
import DeleteIcon from '@mui/icons-material/Delete';
import {Button, CircularProgress, TableBody} from '@mui/material';
import Moment from 'react-moment';

/* In this application we're using Function Components with the State Hooks
 * to manage the states. See the doc: https://reactjs.org/docs/hooks-state.html
 * This App component represents the entire app. It renders a NewItem component
 * and two tables: one that lists the todo items that are to be done and another
 * one with the items that are already done.
 */
function App() {
  // isLoading is true while waiting for the backend to return the list
  // of items. We use this state to display a spinning circle:
  const [isLoading, setLoading] = useState(false);
  // Similar to isLoading, isInserting is true while waiting for the backend
  // to insert a new item:
  const [isInserting, setInserting] = useState(false);
  // The list of todo items is stored in this state. It includes the "done"
  // "not-done" items:
  const [items, setItems] = useState([]);
  // In case of an error during the API call:
  const [error, setError] = useState();


  function deleteItem(deleteId) {
    // console.log("deleteItem("+deleteId+")")
    const myHeaders = new Headers({'Content-Type': 'application/json'});

    fetch(API_LIST + "/" + deleteId, {
      method: 'DELETE',
      headers: myHeaders
    })
        .then(response => {
          // console.log("response=");
          // console.log(response);
          if (response.ok) {
            // console.log("deleteItem FETCH call is ok");
            return response;
          } else {
            throw new Error('Something went wrong ...');
          }
        })
        .then(
            (result) => {
              const remainingItems = items.filter(item => item.id !== deleteId);
              setItems(remainingItems);
            },
            (error) => {
              setError(error);
            }
        );
  }

  function toggleDone(event, id, description, done) {
    event.preventDefault();
    modifyItem(id, description, done).then(
        (result) => {
          reloadOneIteam(id);
        },
        (error) => {
          setError(error);
        }
    );
  }

  function reloadOneIteam(id) {
    const myHeaders = new Headers({'Content-Type': 'application/json'});
    fetch(API_LIST + "/" + id, {
      headers: myHeaders
    })
        .then(response => {
          if (response.ok) {
            return response.json();
          } else {
            throw new Error('Something went wrong ...');
          }
        })
        .then(
            (result) => {
              const items2 = items.map(
                  x => (x.id === id ? {
                    ...x,
                    'description': result.description,
                    'done': result.done
                  } : x));
              setItems(items2);
            },
            (error) => {
              setError(error);
            });
  }

  function modifyItem(id, description, done) {
    const myHeaders = new Headers({'Content-Type': 'application/json'});
    // console.log("deleteItem("+deleteId+")")
    var data = {"description": description, "done": done};
    return fetch(API_LIST + "/" + id, {
      method: 'PUT',
      headers: myHeaders,
      body: JSON.stringify(data)
    })
        .then(response => {
          // console.log("response=");
          // console.log(response);
          if (response.ok) {
            // console.log("deleteItem FETCH call is ok");
            return response;
          } else {
            throw new Error('Something went wrong ...');
          }
        });
  }

  /*
  To simulate slow network, call sleep before making API calls.
  const sleep = (milliseconds) => {
    return new Promise(resolve => setTimeout(resolve, milliseconds))
  }
  */
  useEffect(() => {
        const myHeaders = new Headers({'Content-Type': 'application/json'});
        setLoading(true);
        // sleep(5000).then(() => {
        fetch(API_LIST, {headers: myHeaders})
            .then(response => {
              if (response.ok) {
                return response.json();
              } else {
                throw new Error('Something went wrong ...');
              }
            })
            .then(
                (result) => {
                  setLoading(false);
                  setItems(result);
                },
                (error) => {
                  setLoading(false);
                  setError(error);
                });

        //})
      },
      // https://en.reactjs.org/docs/faq-ajax.html
      [] // empty deps array [] means
      // this useEffect will run once
      // similar to componentDidMount()
  );

  function addItem(text) {
    const myHeaders = new Headers({'Content-Type': 'application/json'});
    console.log("addItem(" + text + ")")
    setInserting(true);
    var data = {};
    console.log(data);
    data.description = text;
    fetch(API_LIST, {
      method: 'POST',
      // We convert the React state to JSON and send it as the POST body
      headers: myHeaders,
      body: JSON.stringify(data),
    }).then((response) => {
      // This API doens't return a JSON document
      console.log(response);
      console.log();
      console.log(response.headers.location);
      // return response.json();
      if (response.ok) {
        return response;
      } else {
        throw new Error('Something went wrong ...');
      }
    }).then(
        (result) => {
          var id = result.headers.get('location');
          var newItem = {"id": id, "description": text}
          setItems([newItem, ...items]);
          setInserting(false);
        },
        (error) => {
          setInserting(false);
          setError(error);
        }
    );
  }

  return (
      <div className="App">
        <h1>MY TODO LIST</h1>
        <NewItem addItem={addItem} isInserting={isInserting}/>
        {error &&
            <p>Error: {error.message}</p>
        }
        {isLoading &&
            <CircularProgress/>
        }
        {!isLoading &&
            <div id="maincontent">
              <table id="itemlistNotDone" className="itemlist">
                <TableBody>
                  {items.map(item => (
                      !item.done && (
                          <tr key={item.id}>
                            <td className="description">{item.description}</td>
                            { /*<td>{JSON.stringify(item, null, 2) }</td>*/}
                            <td className="date"><Moment format="MMM Do hh:mm:ss">{item.createdAt}</Moment></td>
                            <td><Button variant="contained" className="DoneButton"
                                        onClick={(event) => toggleDone(event, item.id, item.description, !item.done)}
                                        size="small">
                              Done
                            </Button></td>
                          </tr>
                      )))}
                </TableBody>
              </table>
              <h2 id="donelist">
                Done items
              </h2>
              <table id="itemlistDone" className="itemlist">
                <TableBody>
                  {items.map(item => (
                      item.done && (

                          <tr key={item.id}>
                            <td className="description">{item.description}</td>
                            <td className="date"><Moment format="MMM Do hh:mm:ss">{item.createdAt}</Moment></td>
                            <td><Button variant="contained" className="DoneButton"
                                        onClick={(event) => toggleDone(event, item.id, item.description, !item.done)}
                                        size="small">
                              Undo
                            </Button></td>
                            <td><Button startIcon={<DeleteIcon/>} variant="contained" className="DeleteButton"
                                        onClick={() => deleteItem(item.id)} size="small">
                              Delete
                            </Button></td>
                          </tr>
                      )))}
                </TableBody>
              </table>
            </div>
        }

      </div>
  );
}

export default App;
