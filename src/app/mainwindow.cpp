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

#include <mainwindow.h>
#include "tf_global_data.h"
#include "tc_log.h"
#include "tc_svga.h"

#include <ks_build_info.h>


#include <QMdiSubWindow>

MainWindow::MainWindow()
   : QMainWindow(), m_ui(new Ui::MainWindow)
{
   m_ui->setupUi(this);

   setWindowTitle(tr("svga_imitator"));
   setWindowIcon(QIcon("://resources/svga.ico"));

#if defined(QT_NO_WEBKIT)
   // webkit temporarily removed, pending overflow issue resolution in CsWebKit
   m_ui->actionAbout_CopperSpice->setVisible(false);
   m_ui->actionAbout_KitchenSink->setVisible(false);
#endif

   _p_global_data = new tf_global_data();

   _label_screen_size = new QLabel( " ");
   _label_current_pos = new QLabel( " ");
   _label_message = new QLabel( " ");

   _status_bar = this->statusBar();
//   _status_bar->addPermanentWidget( _label_screen_size );
   _status_bar->addWidget( _label_screen_size );
   _status_bar->addWidget( _label_current_pos );
   _status_bar->addPermanentWidget( _label_message );

   _p_message_timer = new QTimer();
   _p_message_timer->setSingleShot( true );
   bool ret = connect( _p_message_timer, &QTimer::timeout, this, &MainWindow::onMessageTimer );

   QString str = QString( "Start");
   _status_bar->showMessage( str, 2000 );


   connect(m_ui->actionClose_Window,      &QAction::triggered, this,  &MainWindow::actionClose_Window);
   connect(m_ui->actionCloseAll_Windows,  &QAction::triggered, this,  &MainWindow::actionCloseAll_Windows);
   connect(m_ui->actionExit_Program,      &QAction::triggered, this,  &MainWindow::actionExit_Program);

   connect(m_ui->actionLog,              &QAction::triggered, this,  &MainWindow::actionLog);

   connect( _p_global_data, &tf_global_data::updateScreenSize, this, &MainWindow::updateScreenSize );
   connect( _p_global_data, &tf_global_data::updateScreenPos , this, &MainWindow::updateScreenPos );
   connect( _p_global_data, &tf_global_data::showStatusMessage , this, &MainWindow::showStatusMessage );

#ifdef Q_OS_MAC
   setUnifiedTitleAndToolBarOnMac(true);
#endif


    this->setMinimumHeight( 900 );
    this->setMinimumWidth( 1044 );

    actionSvga();
    //actionLog();


   

}

MainWindow::~MainWindow()
{
   delete m_ui;
   delete _p_global_data; _p_global_data = NULL;
}

void MainWindow::updateScreenSize( uint h_size, uint v_size )
{
   char str[128];
   sprintf( str, " SVGA:  %-5dx%5d ", h_size, v_size );
   QString qs = QString::fromLatin1( str );
   _label_screen_size->setText( qs );
   emit updateSvgaScreen();

}

void MainWindow::updateScreenPos(  uint cadr, uint h_pos, uint v_pos )
{
   char str[128];
   sprintf( str, " Cadr: %4d Pos: %5d %5d ", cadr, h_pos, v_pos );
   QString qs = QString::fromLatin1( str );
   _label_current_pos->setText( qs );
   emit updateSvgaScreen();
}

void MainWindow::changeEvent(QEvent *event)
{
   if (event->type() == QEvent::LanguageChange) {
      m_ui->retranslateUi(this);
   }

   // calls parent, will change the title bar
   QMainWindow::changeEvent(event);
}

void MainWindow::addMdiChild(QWidget *oDw)
{
   QMdiSubWindow *subWindow = m_ui->mdiArea->addSubWindow(oDw);
   subWindow->show();
}

// file
void MainWindow::actionClose_Window()
{
   QMdiSubWindow *temp = m_ui->mdiArea->currentSubWindow();

   if (temp) {
      temp->close();
   }
}

void MainWindow::actionCloseAll_Windows()
{
   m_ui->mdiArea->closeAllSubWindows();
}

void MainWindow::actionExit_Program()
{
   close();
}

void MainWindow::actionLog()
{

    if( tc_log::_p_instance )
    {
        tc_log::_p_instance->show();
        tc_log::_p_instance->setFocus();
    } else 
    {
        tc_log *oDw = new tc_log( 0, _p_global_data);
        addMdiChild(oDw);
    }
}

void MainWindow::actionSvga()
{
   if( tc_svga::_p_instance)
   {
      tc_svga::_p_instance->show();
      tc_svga::_p_instance->setFocus();

   } else 
   {
    tc_svga *oDw = new tc_svga( 0, _p_global_data);
    addMdiChild(oDw);

    connect( this, &MainWindow::updateSvgaScreen, oDw, &tc_svga::updateSvgaScreen );

   }
}


void MainWindow::showStatusMessage(QString &str, uint time_ms)
{
   _label_message->setText( str );
   if( time_ms )
   {
      _p_message_timer->setInterval( time_ms );
      _p_message_timer->setSingleShot( true );
      _p_message_timer->start();
      //QTimer::singleShot(time_ms, Qt::CoarseTimer, this, SLOT(onMessageTimer()));
   }
}

void MainWindow::onMessageTimer()
{
   _label_message->setText( "" );
   _p_message_timer->stop();
}