"use client"

import "./new-item.css"
import {useState} from "react";
import {Button, CircularProgress} from "@mui/material";

export default function NewItem(props) {

    const [input, setInput] = useState("")
    const [error, setError] = useState(false)
    let addItem = props.addItem

    let handleChange = (e) => {
        e.target.value.length > 0 && setError(false)
        setInput(e.target.value)

    }

    let handleSubmit = (_) => {
        let success = addItem(input);
        success && setInput("");
    }

    let displayAddButtonValue = () => {
        if (props.loading) {return <CircularProgress className={"progress"} size={"1rem"} color={"inherit"}/>}
        else {return "Add"}
    }
    
    let showInputRequiredWarning = () => {
        return !input.length > 0 && error ? "required" : ""
    }

    let displayError = () => {
        if (error) return "*This field is required."
    }

    return (
        <div className={"new-item-component flex flex-col"}>
            <div className={"flex flex-row"}>
            <input
                id="newiteminput"
                placeholder="New Task"
                className={showInputRequiredWarning()}
                type="text"
                autoComplete="off"
                value={input}
                onChange={handleChange}
                onKeyDown={event => {
                    if (event.key === 'Enter' && !props.loading) {
                        if (input.length === 0) {
                            setError(true)
                        }
                        input.length > 0 && handleSubmit(event);
                    }
                }}
            />
            <Button
                className="AddButton"
                variant="contained"
                disabled={props.loading}
                size="small"
                onClick={ e => {
                    if (input.length === 0) {
                        setError(true)
                    }
                    input.length > 0 && handleSubmit(e); }}>

                {
                    displayAddButtonValue()
                }
            </Button>
            </div>
            <div className={"error-message"}>{ displayError() }</div>

        </div>
    )
}