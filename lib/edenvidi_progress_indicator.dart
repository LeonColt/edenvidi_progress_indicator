library edenvidi_progress_indicator;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef Widget ProgressDialogBuilder( final int height, final String message, final double progress );

class ProgressDialog {
	final GlobalKey<_LoadingIndicatorState> _indicator_state = new GlobalKey();
	final ProgressDialogBuilder builder;
	final BuildContext context;
	Widget dialog;
	BuildContext _dialog_context;
	String _message;
	double _progress;
	
	bool _is_showing = false;
	ProgressDialog( {
		@required this.context,
		final String message = "Loading...",
		final double progress,
		this.builder,
	} ): _message = message, _progress = progress, assert( context != null );
	
	bool get isShowing => _is_showing;
	String get message => _message;
	
	set message( final String message ) {
		_message = message;
		_indicator_state.currentState.message = message;
	}
	
	set progress( final double progress ) {
		_progress = progress;
		_indicator_state.currentState.progress = progress;
	}
	void hide() {
		if (_is_showing) {
			_is_showing = false;
			Navigator.of(_dialog_context).pop();
		}
	}
	
	void show() {
		if (!_is_showing) {
			if ( dialog == null ) dialog = new _LoadingIndicator( key: _indicator_state, message: _message, );
			_is_showing = true;
			showDialog<dynamic>(
				context: context,
				barrierDismissible: false,
				builder: (BuildContext context) {
					_dialog_context = context;
					return new Dialog(
						insetAnimationCurve: Curves.easeInOut,
						insetAnimationDuration: Duration(milliseconds: 100),
						elevation: 10.0,
						shape: RoundedRectangleBorder( borderRadius: BorderRadius.all( Radius.circular( 10.0 ) ) ),
						child: dialog,
					);
				},
			);
		}
	}
}

class _LoadingIndicator extends StatefulWidget {
	final String message;
	final double progress;
	final ProgressDialogBuilder builder;
	const _LoadingIndicator( { Key key, this.message, this.builder, this.progress } ): super( key: key );
	@override
	State<StatefulWidget> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator> {
	String _message;
	double _progress;
	@override
	Widget build(BuildContext context) => new WillPopScope(
		onWillPop: () => Future.value(false),
		child: new Container(
			padding: const EdgeInsets.all(10.0),
			height: 100,
			child: widget.builder != null ? widget.builder(100, _message, _progress) : new Row(
				children: <Widget>[
					new CircularProgressIndicator(
						value: _progress,
					),
					new SizedBox(width: 10, height: 100,),
					new Expanded(
						child: new Text(
							_message,
							style: const TextStyle(
								color: Colors.black,
								fontSize: 22.0,
								fontWeight: FontWeight.w700,
							),
						),
					),
				],
			),
		),
	);
	
	set message( final String message ) {
		if ( mounted ) setState(() => _message = message );
	}
	
	set progress( final double progress ) {
		if ( mounted ) setState( () => _progress = progress );
	}
	
	@override
	void initState() {
		_message = widget.message;
		_progress = widget.progress;
		super.initState();
	}
}