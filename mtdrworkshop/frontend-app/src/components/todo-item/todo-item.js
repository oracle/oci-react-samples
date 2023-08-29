
// MyToDoReact version 2.0.0
//
// Copyright (c) 2021 Oracle, Inc.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

import "./todo-item.css"
import {Button} from "@mui/material";
import DeleteIcon from '@mui/icons-material/Delete';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline';
import Moment from "react-moment";

export default function ToDoItem(props) {

    let taskIsIncomplete = (i) => {
        return (
            <td>
            <Button
                startIcon={<CheckCircleOutlineIcon/>}
                className="DoneButton"
                variant="contained"
                disabled={false}
                onClick={(_) => props.toggleItem(i)}
                size="small"
            >
                DONE
            </Button>
            </td>
        )
    }

    let taskIsComplete = (i) => {
        return (
            <td className={"row"}>
                <Button
                    variant="contained" className="DoneButton"
                    size="small"
                    onClick={(_) => props.toggleItem(i)}
                >
                    UNDO
                </Button>
                <Button

                    startIcon={<DeleteIcon />}
                    variant="contained" className="DeleteButton"
                    size="small"
                    onClick={() => props.deleteItem(i)}
                >
                    DELETE
                </Button>
            </td>
        )
    }

    let taskDone = props.item.done ? taskIsComplete(props.index) : taskIsIncomplete(props.index)
    return (
        <tr className={"todo-component flex flex-row"}>
            <td key={props.item.id} className={"description"}>{props.item.description}</td>
            <td className="date"><Moment format="MMM Do hh:mm:ss">{props.item.createdAt}</Moment></td>
            { taskDone }
        </tr>
    )
}