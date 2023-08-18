import "./error.css";
import CloseIcon from '@mui/icons-material/Close';
import ErrorIcon from '@mui/icons-material/Error';
export default function DisplayError (props) {

    let message = props.error ? props.error.toString(): null;
    let clear = props.clear;
    let display = () => {
        return props.error ? (
            <div className={"error flex flex-row flex-between"} >
                <div className={"flex flex-row"}>
                    <ErrorIcon/>
                    <div className={"message"}>{message}</div>
                </div>

                <div><CloseIcon className={"closeButton"} onClick={()=>clear()}/></div>
            </div>
        ) : null;
    }

    return (
        <div>{display()}</div>
    )
}