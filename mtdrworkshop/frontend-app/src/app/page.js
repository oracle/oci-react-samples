"use client"

import styles from './page.module.css'
import NewItem from "@/components/new-item/new-item";
import {useEffect, useState} from "react";
import ToDoItem from "@/components/todo-item/todo-item";
import {create, del, retrieve, update} from "@/app/api";
import {CircularProgress, TableBody} from "@mui/material";
import DisplayError from "@/components/error/error";

export default function Home() {

    const [items, setItems] = useState([])
    const [loading, setLoading] = useState(false)
    const [inserting, setInserting] = useState(false)
    const [error, setError] = useState(null)

    useEffect(() => {
        setLoading(true)
        retrieve()
            .then(result => {
                if (result.items.length) {
                    setItems(result.items)
                }
                setLoading(false);
            })
            .catch(error => {setError(error); setLoading(false)});
    }, []);

    let addItem = (s) => {
        setInserting(true)
        if (s.trim() === "") return;
        let newItem = { description: s.trim(), done: false }

         create(newItem)
            .then(result => {
                newItem.id = Number(result.headers.get("location"));
                newItem.createdAt = result.headers.get("timestamp")

                let newItems = [newItem, ...items];
                setItems(newItems);
                setInserting(false);

            }).catch( error => {
            setError(error);
            setInserting(false);
        })
        return error === null

    }

    let toggleItem = (id) => {
        let data = items.find(v =>  v.id === id);
        data.done = !data.done;

        update(id, data)
            .then((result) => {
                let newItems = items.map(v => {if (v.id === id) {
                    v.done = Boolean(result.done);
                    v.description = result.description
                } return v });
                setItems(newItems);

            })
            .catch((error) => {
                setError(error)
            })

    }

    let deleteItem = (id) => {
        del(id)
            .then((_) => {
                let remainingItems = items.filter(v => v.id !== id );
                setItems(remainingItems);
            })
            .catch((error) => {
                setError(error)
            })
    }

    let done_listing = items.length ? items.filter(v => v.done): []
    let todo_listing = items.length ? items.filter(v => !v.done): []


    let displayDone = () => {
        if (done_listing.length > 0) {
            return (
                <div className={styles.section + " flex flex-col"}>{ <h1 className={styles.title}>My Completed TODOs</h1> }
                    <table>
                        <TableBody className={styles.bottom}>
                            {
                                done_listing.map((v, i) =>  <ToDoItem key={i}  index={v.id}  item={v} toggleItem={toggleItem} deleteItem={deleteItem}/>)
                            }
                        </TableBody>
                    </table>
                </div>

            )
        }
    }

    let clearError = () => {
        setError(null)
    }



    return (
        <main className={styles.main}>

            <div className={styles.section + " flex flex-col"}>
                <div className={styles.description}>
                    <h1 className={styles.title}>My TODO List</h1>
                    <NewItem addItem={addItem} loading={inserting}/>
                    <DisplayError error={error} clear={clearError}/>
                    <table>
                    <TableBody className={styles.bottom}>
                        {
                            todo_listing.map((v, i) =>
                                <ToDoItem key={i}  index={v.id}  item={v} toggleItem={toggleItem} deleteItem={deleteItem}/>
                            )
                        }
                    </TableBody>
                    </table>
                </div>
            </div>
            <div className={"flex flex-row flex-center"}>{loading && <CircularProgress size={"3rem"} style={{'color': '#a4a4a4'}}/>}</div>
            {displayDone()}
        </main>
  )
}
