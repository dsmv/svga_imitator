/***********************************************************************
*
* Copyright (c) 2012-2024 Barbara Geller
* Copyright (c) 2012-2024 Ansel Sermersheim
* Copyright (c) 2015 The Qt Company Ltd.
*
* This file is part of KitchenSink.
*
* KitchenSink is free software, released under the BSD 2-Clause license.
* For license details refer to LICENSE provided with this project.
*
* KitchenSink is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*
* https://opensource.org/licenses/BSD-2-Clause
*
***********************************************************************/

#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <ui_mainwindow.h>

#include <QMainWindow>
#include <QLabel>
#include <QStatusBar>

class tf_global_data;
//class tc_log;

class MainWindow : public QMainWindow
{
   CS_OBJECT(MainWindow)

 public:
   explicit MainWindow();
   ~MainWindow();
   void addMdiChild(QWidget *);

 protected:
   void changeEvent(QEvent *event) override;

 private:
   // slot methods can be declared as standard methods when using method pointers in connect()

   void actionClose_Window();
   void actionCloseAll_Windows();
   void actionExit_Program();

   void actionLog();
   void actionSvga();
   
    Ui::MainWindow *m_ui;

    tf_global_data  *_p_global_data;


    void updateScreenSize( uint h_size, uint v_size );
    void updateScreenPos(  uint cadr, uint h_pos, uint v_pos );

    QLabel      *_label_screen_size;
    QLabel      *_label_current_pos;
    QStatusBar  *_status_bar;
};


#endif
