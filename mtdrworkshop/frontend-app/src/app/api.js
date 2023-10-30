// MyToDoReact version 2.0.0
//
// Copyright (c) 2021 Oracle, Inc.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
const ROOT_API = process.env.NEXT_PUBLIC_ROOT_API ? process.env.NEXT_PUBLIC_ROOT_API : ""


async function retrieve_prod() {
    return await fetch(ROOT_API+"/api/todolist")
        .then(response => {
            if (response.ok) {
                return response.json();
            } else {
                throw new Error('Error: Failed to retrieve list');
            }
        });

}

async function retrieve_dev() {
    return new Promise(resolve => {
        resolve({"items": []})
    })

}

async function del_prod(id) {
    return await fetch(ROOT_API+"/api/todolist/"+id, { method: 'DELETE',
    }).then(response => {
            if (response.ok) {
                return response;
            } else {
                throw new Error('Error: Failed to delete task');
            }
        })
}

async function del_dev() {
    return new Promise( resolve => {
        resolve()
    })
}

async function update_prod(id, data) {
    return await fetch(ROOT_API+"/api/todolist/"+id, {method: 'PUT',
        body: JSON.stringify(data), headers: {"content-type": "application/json"}})
        .then(response => {
            if (response.ok) {
                return response.json();
            } else {
                throw new Error('Error: Failed to update task');
            }
        })
}

async function update_dev(id, data) {
    return new Promise( resolve => {
        resolve(data)
    })
}
async function create_prod(data) {
    return await fetch(ROOT_API + "/api/todolist", {
        method: 'POST', body: JSON.stringify(data), headers: {"content-type": "application/json"}
    }).then((response) => {
        if (response.ok) {
            return response;
        } else {
            console.log("error")
            throw new Error('Error: Failed to create task');
        }
    })
}

async function create_dev(data) {
    return new Promise(resolve => {
        const randomId = function(length = 6) {
            return Math.random().toString(36).substring(2, length+2);
        };
        let id = randomId(7)
        let ts = Number(new Date());
        let headers = {
            get: (value) => {
                if (value === "location") return id
                else if (value === "timestamp") return ts
            }
        }
        resolve({"headers": headers})
    })
}

if (process.env.NODE_ENV === 'development') {
    module.exports.create = create_dev;
    module.exports.del = del_dev;
    module.exports.update = update_dev;
    module.exports.retrieve = retrieve_dev;
} else {
    module.exports.create = create_prod;
    module.exports.del = del_prod;
    module.exports.update = update_prod;
    module.exports.retrieve = retrieve_prod;
}