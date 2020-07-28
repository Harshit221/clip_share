/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package server;

import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Server {

  String data;
  int port = 5669;
  Clipboard c = Toolkit.getDefaultToolkit().getSystemClipboard();

  String getData() {
    return data;
  }

  synchronized void setData(String data) {
    this.data = data;
  }

  void communicate() throws IOException {

    Thread inputThread = null, outputThread = null;
    ServerSocket server = new ServerSocket(port);
    System.out.println("Address: " + InetAddress.getLocalHost().getHostAddress());
    System.out.println("Port: " + port);
    server.setSoTimeout(0);
    Socket client;
    while (true) {
      try {
        System.out.println("waiting for connection...");
        client = server.accept();
        System.out.println("Connected");
        inputThread = new InputThread(client.getInputStream());
        outputThread = new OutputThread(new DataOutputStream(client.getOutputStream()));
        inputThread.start();
        outputThread.start();
        while (client.isConnected()) {

        }

      } catch (Exception e) {
        if (inputThread != null) {
          inputThread.stop();
        }
        if (outputThread == null) {
          outputThread.stop();
        }
        System.out.println(e);
      }
    }
  }
  
  String getClipboardData() throws UnsupportedFlavorException, IOException {
    return c.getData(DataFlavor.stringFlavor).toString();
  }
  
  void setClipboardData(String data) {
    StringSelection selection = new StringSelection(data);
    c.setContents(selection, selection);
  }

  public static void main(String[] args) throws IOException, UnsupportedFlavorException {
 
    Server server = new Server();
    server.communicate();
    
  }

//  private native String getClipboardData();
//
//  private native void setClipboardData(String data);

  class InputThread extends Thread {

    final InputStream input;
    String temp;
    
    InputThread(InputStream input) {
      this.input = input;
    }

    @Override
    public void run() {
      while (true) {
        try {
          byte[] b = new byte[2048];
          input.read(b);
          temp = new String(b);
          System.out.println("Received: " + temp);
          if (!temp.equals(getData())) {
            setData(temp);
              setClipboardData(data);
          }
        } catch (IOException ex) {
          Logger.getLogger(Server.class.getName()).log(Level.SEVERE, null, ex);
        } catch(NullPointerException e) {
          this.stop();
        }
      }
    }

  }

  class OutputThread extends Thread {

    String temp;
    final DataOutputStream output;

    OutputThread(DataOutputStream output) {
      this.output = output;
    }

    @Override
    public void run() {
      while (true) {
        try {
          TimeUnit.SECONDS.sleep(1);
          temp = getClipboardData();
          if (!temp.equals(getData())) {
            System.out.println("Sending: " + temp);
            setData(temp);
            output.writeUTF(data);
          }
        } catch (InterruptedException | IOException ex) {
          System.out.println(ex);
        } catch(NullPointerException e) {
          this.stop();
        } catch (UnsupportedFlavorException ex) {
          Logger.getLogger(Server.class.getName()).log(Level.SEVERE, null, ex);
        }
      }
    }
  }
}
