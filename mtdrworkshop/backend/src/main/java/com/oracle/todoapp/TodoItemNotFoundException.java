/*
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
*/
package com.oracle.todoapp;

/*
 * @author  jean.de.lavarene@oracle.com
 */
public class TodoItemNotFoundException extends RuntimeException {
  private static final long serialVersionUID = -7836707150113921385L;

  public TodoItemNotFoundException(String id) {
    super("TodoItem:" + id + " was not found!");
  }
}
