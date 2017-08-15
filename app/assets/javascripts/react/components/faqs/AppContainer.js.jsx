// var AppContainer = React.createClass({
class AppContainer extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      heading: 'FAQ Index',
      modalContent: null,
    };

    this.openModal = this.openModal.bind(this);
    this.closeModal = this.closeModal.bind(this);
  }

  componentDidMount() {
    this.ee = ee;
    this.ee.on('openModal', this.openModal);
    this.ee.on('closeModal', this.closeModal);
  }

  openModal(content) {
    console.log(content);
    this.setState({
      modalContent: <MyEditor key={2} />,
    });
  }

  closeModal() {
    this.setState({
      modalContent: null
    })

  }

  render() {

    return (
      <App heading={this.state.heading} modalContent={this.state.modalContent} />
    );
  }
};
