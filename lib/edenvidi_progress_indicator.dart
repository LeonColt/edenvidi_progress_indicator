library edenvidi_progress_indicator;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

typedef Widget ProgressDialogBuilder( final double height, final String message, final double progress );


class ProgressDialog {
	final GlobalKey<_LoadingIndicatorState> _indicator_state = new GlobalKey();
	final ProgressDialogBuilder builder;
	final Color background_color;
	final ShapeBorder shape_border;
	final double height;
	String _message;
	double _progress;
	
	bool _is_dimissed = false;
	final _lock = new Lock();
	
	ProgressDialog( {
		final String message = "Loading...",
		final double progress,
		this.builder,
		this.background_color,
		this.shape_border = const RoundedRectangleBorder( borderRadius: BorderRadius.all( Radius.circular( 10.0 ) ) ),
		this.height = 100,
	} ): _message = message, _progress = progress;
	
	bool get isShowing => !_is_dimissed;
	String get message => _message;
	
	set message( final String message ) {
		_message = message;
		if ( _indicator_state.currentState != null ) _indicator_state.currentState.message = message;
	}
	
	set progress( final double progress ) {
		_progress = progress;
		if ( _indicator_state.currentState != null ) _indicator_state.currentState.progress = progress;
	}
	
	void show( final BuildContext context ) async {
		_is_dimissed = false;
		showGeneralDialog(
			context: context,
			pageBuilder: ( context, animation1, animation2 ) => new Dialog(
				insetAnimationCurve: Curves.easeInOut,
				insetAnimationDuration: Duration(milliseconds: 100),
				elevation: 10.0,
				backgroundColor: background_color,
				shape: shape_border,
				child: new _LoadingIndicator( key: _indicator_state, message: _message, height: height, builder: builder, ),
			),
			barrierDismissible: false,
			transitionDuration: Duration(milliseconds: 500),
		).then( ( dismissed ) {
			_is_dimissed = dismissed;
		});
	}
	
	void dismiss( BuildContext context ) async {
		await _lock.synchronized( () async {
			if ( !_is_dimissed ) Navigator.of(context, rootNavigator: true).pop(true);
		});
	}
}

class _LoadingIndicator extends StatefulWidget {
	final String message;
	final double progress;
	final ProgressDialogBuilder builder;
	final double height;
	const _LoadingIndicator( {
		Key key,
		@required this.message,
		@required this.height,
		this.builder,
		this.progress
	} ): assert( message != null ), assert( height != null ), super( key: key );
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
			height: widget.height,
			child: widget.builder != null ? widget.builder(widget.height, _message, _progress) : new Row(
				children: <Widget>[
					new CircularProgressIndicator(
						value: _progress,
					),
					new SizedBox(width: 10, height: widget.height,),
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