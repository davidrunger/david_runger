declare module 'chartkick' {
  interface ChartkickInterface {
    use(adapter: unknown): ChartkickInterface;
  }

  const Chartkick: ChartkickInterface;
  export default Chartkick;
}
